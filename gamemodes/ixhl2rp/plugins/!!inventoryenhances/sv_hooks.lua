util.AddNetworkString("ixInventoryDragCombine")
util.AddNetworkString("ixInventoryCombineAction")
util.AddNetworkString("ixInventorySplitAction")

function ix.item.PerformInventoryCombineAction(client, action, item, targetItem, invID, data)
	local character = client:GetCharacter()

	if (!character) then
		return
	end

	local inventory = ix.item.inventories[invID or 0]

	if (!inventory:OnCheckAccess(client) or !inventory:GetItemByID(item)) then
		return
	end

	item = ix.item.instances[item]
	targetItem = ix.item.instances[targetItem]

	if (!item or !targetItem) then
		return
	end

	local targetInventory = ix.item.inventories[targetItem.invID or 0]

	if (!targetInventory:OnCheckAccess(client) or !targetInventory:GetItemByID(targetItem.id)) then
		return
	end

	if (hook.Run("CanPlayerCombineItem", client, item, targetItem) == false) then
		return
	end

	item.player = client
	targetItem.player = client

	if !action then
		if (item.Combine) then
			item:Combine(targetItem)
		end

		item.player = nil
		targetItem.player = nil

		return
	else
		local callback = (item.combine or {})[action]

		if (callback) then
			if (callback.OnCanRun and callback.OnCanRun(item, targetItem, data) == false) then
				item.player = nil
				targetItem.player = nil

				return
			end

			--hook.Run("PlayerInteractItem", client, action, item)

			local result

			--if (item.hooks[action]) then
			--	result = item.hooks[action](item, data)
			--end

			result = callback.OnRun(item, targetItem, data)

			--if (item.postHooks[action]) then
				-- Posthooks shouldn't override the result from OnRun
				--item.postHooks[action](item, result, data)
			--end

			if (result != false) then
				item:Remove()
			end

			item.player = nil
			targetItem.player = nil

			return result != false
		end
	end
end

net.Receive("ixInventoryDragCombine", function(length, client)
	ix.item.PerformInventoryCombineAction(client, nil, net.ReadUInt(32), net.ReadUInt(32), net.ReadUInt(32))
end)

net.Receive("ixInventoryCombineAction", function(length, client)
	ix.item.PerformInventoryCombineAction(client, net.ReadString(), net.ReadUInt(32), net.ReadUInt(32), net.ReadUInt(32), net.ReadTable())
end)

function ix.item.PerformSplit(self, invID, x, y, client)
	invID = invID or 0

	if (self.invID == invID) then
		return false, "same inv"
	end

	local inventory = ix.item.inventories[invID]
	local curInv = ix.item.inventories[self.invID or 0]

	if (curInv and !IsValid(client)) then
		client = curInv.GetOwner and curInv:GetOwner() or nil
	end

	if (curInv) then
		if (invID and invID > 0 and inventory) then
			local targetInv = inventory
			local bagInv

			if (!x and !y) then
				x, y, bagInv = inventory:FindEmptySlot(self.width, self.height)
			end

			if (bagInv) then
				targetInv = bagInv
			end

			if (!x or !y) then
				return false, "noFit"
			end

			local prevID = self.invID
			local status, result --=  create split item

			if (status) then
				if (self.invID > 0 and prevID != 0) then
					if (self.OnSplit) then
						self:OnSplit(curInv, inventory)
					end

					hook.Run("OnItemSplit", self, curInv, inventory)
					return true
				end
			else
				return false, result
			end
		elseif (IsValid(client)) then
			if (self.OnSplit) then
				self:OnSplit(curInv, inventory)
			end

			hook.Run("OnItemSplit", self, curInv, inventory)

			-- create split entity

			return true
		else
			return false, "noOwner"
		end
	else
		return false, "invalidInventory"
	end
end

net.Receive("ixInventorySplitAction", function(length, client)
	local oldX, oldY, x, y = net.ReadUInt(6), net.ReadUInt(6), net.ReadUInt(6), net.ReadUInt(6)
	local invID, newInvID = net.ReadUInt(32), net.ReadUInt(32)

	local character = client:GetCharacter()

	if (character) then
		local inventory = ix.item.inventories[invID]

		if (!inventory or inventory == nil) then
			inventory:Sync(client)
		end

		if ((!inventory.owner or (inventory.owner and inventory.owner == character:GetID())) or
			inventory:OnCheckAccess(client)) then
			local item = inventory:GetItemAt(oldX, oldY)

			if (item) then
				if (newInvID and invID != newInvID) then
					local inventory2 = ix.item.inventories[newInvID]

					if (inventory2) then
						local bStatus, error --= Split to another inv 
						--item:Transfer(newInvID, x, y, client)

						if (!bStatus) then
							client:NotifyLocalized(error or "unknownError")
						end
					end

					return
				end

				if (inventory:CanItemFit(x, y, item.width, item.height, item)) then
					-- split to this inv
				end
			end
		end
	end
end)

local function NetworkInventoryMove(receiver, invID, itemID, oldX, oldY, x, y)
	net.Start("ixInventoryMove")
		net.WriteUInt(invID, 32)
		net.WriteUInt(itemID, 32)
		net.WriteUInt(oldX, 6)
		net.WriteUInt(oldY, 6)
		net.WriteUInt(x, 6)
		net.WriteUInt(y, 6)
	net.Send(receiver)
end

-- Snap the client's view of an item back to its authoritative server position.
-- Used whenever we reject a move so the icon doesn't get stuck in mid-air.
local function SnapItemBack(client, item)
	if (!IsValid(client) or !item) then return end

	NetworkInventoryMove(
		client,
		item.invID or 0,
		item:GetID(),
		item.gridX or 1, item.gridY or 1,
		item.gridX or 1, item.gridY or 1
	)
end

-- Returns true if (x, y) + (w-1, h-1) fits inside the given inventory.
local function IsInBounds(inv, x, y, w, h)
	w = w or 1
	h = h or 1

	return x and y and x > 0 and y > 0 and (x + w - 1) <= inv.w and (y + h - 1) <= inv.h
end

net.Receive("ixInventoryMove", function(length, client)
	local oldX, oldY, x, y = net.ReadUInt(6), net.ReadUInt(6), net.ReadUInt(6), net.ReadUInt(6)
	local invID, newInvID = net.ReadUInt(32), net.ReadUInt(32)

	local character = client:GetCharacter()

	if (!character) then return end

	local inventory = ix.item.inventories[invID]

	if (!inventory) then
		-- nothing we can do here; silently drop the packet rather than
		-- calling :Sync on a nil value like the previous version did.
		return
	end

	if (not ((!inventory.owner or (inventory.owner and inventory.owner == character:GetID())) or
		inventory:OnCheckAccess(client))) then
		local item = inventory:GetItemAt(oldX, oldY)

		if (item) then
			SnapItemBack(client, item)
		end

		return
	end

	local item = inventory:GetItemAt(oldX, oldY)

	if (!item) then return end

	-- Cross-inventory move: delegate to Transfer which has its own checks.
	if (newInvID and invID != newInvID) then
		local inventory2 = ix.item.inventories[newInvID]

		if (!inventory2) then
			SnapItemBack(client, item)
			return
		end

		-- Coerce equipment destination coordinates (x=1, y in [1,h]) so the
		-- target inventory's Add never sees out-of-range writes.
		if (inventory2.vars and inventory2.vars.isEquipment) then
			x = 1

			if (!y or y < 1 or y > inventory2.h) then
				SnapItemBack(client, item)
				client:NotifyLocalized("noFit")
				return
			end
		elseif (not IsInBounds(inventory2, x, y, item.width, item.height)) then
			SnapItemBack(client, item)
			client:NotifyLocalized("noFit")
			return
		end

		local bStatus, error = item:Transfer(newInvID, x, y, client)

		if (!bStatus) then
			SnapItemBack(client, item)
			client:NotifyLocalized(error or "unknownError")
		end

		return
	end

	-- Same-inventory move from this point on.
	local isEquip = inventory.vars and inventory.vars.isEquipment

	-- Coordinate validation: reject any bad coordinate set before we touch
	-- in-memory state or the DB. Previously the equipment branch trusted
	-- client input and could persist x=0 / y>MAX_EQUIPMENT_SLOTS, then the
	-- restore step would silently delete the item on next load.
	if (isEquip) then
		x = 1

		if (!oldY or oldY < 1 or oldY > inventory.h or
			!y or y < 1 or y > inventory.h) then
			SnapItemBack(client, item)
			return
		end
	else
		if (not IsInBounds(inventory, oldX, oldY, item.width, item.height) or
			not IsInBounds(inventory, x, y, item.width, item.height)) then
			SnapItemBack(client, item)
			return
		end
	end

	if (not inventory:CanItemFit(x, y, item.width, item.height, item)) then
		SnapItemBack(client, item)
		return
	end

	item.gridX = x
	item.gridY = y

	if (isEquip) then
		-- Equipment is a 1-wide column where each row IS a slot index
		-- (HEAD=1, ..., RESERVED4=16). Each item occupies exactly one
		-- cell keyed by item.slot; item.width/height are only used for
		-- icon sizing in generic grids, never for slot occupancy here.
		inventory.slots[1] = inventory.slots[1] or {}
		inventory.slots[1][oldY] = nil
		inventory.slots[1][y] = item
	else
		for x2 = 0, item.width - 1 do
			for y2 = 0, item.height - 1 do
				local previousX = inventory.slots[oldX + x2]

				if (previousX) then
					previousX[oldY + y2] = nil
				end
			end
		end

		for x2 = 0, item.width - 1 do
			for y2 = 0, item.height - 1 do
				inventory.slots[x + x2] = inventory.slots[x + x2] or {}
				inventory.slots[x + x2][y + y2] = item
			end
		end
	end

	local receivers = inventory:GetReceivers()

	if (istable(receivers)) then
		local filtered = {}

		for _, v in ipairs(receivers) do
			if (v != client) then
				filtered[#filtered + 1] = v
			end
		end

		if (#filtered > 0) then
			NetworkInventoryMove(filtered, invID, item:GetID(), oldX, oldY, x, y)
		end
	end

	if (!inventory.noSave) then
		local query = mysql:Update("ix_items")
			query:Update("x", x)
			query:Update("y", y)
			query:Where("item_id", item.id)
		query:Execute()
	end
end)

local LAYER = {}
LAYER.__index = LAYER

LAYER.item = false
LAYER.model = false
LAYER.bodygroups = {}

function LAYER:__tostring()
	return "LAYER"
end

local OUTFIT = {}
OUTFIT.__index = OUTFIT

function OUTFIT:__tostring()
	return "OUTFIT"
end

function OUTFIT:Init(client)
	self.items = {}
	self.layers = {}
	self.client = client

	local base = setmetatable({}, LAYER)
	base.item = false
	base.model = client:GetCharacter():GetModel()
	base.bodygroups = {}

	for i = 0, (client:GetNumBodyGroups() - 1) do
		base.bodygroups[i] = 0
	end
/*
	local customBodygroups = client:GetCharacter():GetData("groups", {})

	for k, v in pairs(customBodygroups) do
		base.bodygroups[k] = v
	end
*/
	self.layers[1] = base
end

function OUTFIT:AddItem(item, mdl, bodygroups)
	local layer = setmetatable({}, LAYER)
	layer.item = item
	layer.model = mdl or false
	layer.bodygroups = table.Copy(bodygroups)

	table.insert(self.layers, layer)
end

function OUTFIT:RemoveItem(item)
	for k, v in ipairs(self.layers) do
		if k == 1 then continue end

		if v.item == item then
			table.remove(self.layers, k)
			break
		end
	end
end

function OUTFIT:GetResult()
	local max = 0
	for k, v in ipairs(self.layers) do
		if #v.bodygroups > max then
			max = #v.bodygroups
		end
	end
	local bodygroups = table.Copy(self.layers[1].bodygroups)
	while #bodygroups < max do
		table.insert(bodygroups, 0)
	end
	local model = self.client:GetCharacter():GetModel()

	for k, v in ipairs(self.layers) do
		if k == 1 then continue end

		for z, x in pairs(bodygroups) do
			bodygroups[z] = v.bodygroups[z] or x
		end

		model = v.model or model
	end

	return model, bodygroups
end

function OUTFIT:UpdateModel(client, model, bodygroups)
	if model and client:GetModel() != model then
		client:SetModel(model)
	end

	for k, v in pairs(bodygroups) do
		client:SetBodygroup(k, v)
	end
end

-- Re-apply the visual / mechanical effects of any currently-equipped items.
-- Called both during CharacterLoaded and on respawn; the respawn path used
-- to invoke the whole CharacterLoaded which would re-enter the equipment
-- creation branch and could race a second inventory into existence.
local function ReapplyEquipment(character, client)
	if (!IsValid(client) or !character) then return end

	local equipment = character:GetEquipment()

	if (!equipment) then return end

	local items = equipment:GetItems()
	local torso = equipment:GetItemAtSlot(EQUIP_TORSO)
	local mask = equipment:GetItemAtSlot(EQUIP_MASK)

	if (torso and torso.OnEquipped) then
		timer.Simple(2, function()
			if (IsValid(client)) then
				torso:OnEquipped(client, torso.slot)
			end
		end)
	end

	if (mask and mask.OnEquipped) then
		timer.Simple(2.1, function()
			if (IsValid(client)) then
				mask:OnEquipped(client, mask.slot)
			end
		end)
	end

	for _, v in pairs(items) do
		if (v.OnEquipped) then
			v:OnEquipped(client, v.slot)
		end
	end
end

-- Synthetic inventory ID space for bot equipment inventories. Bot characters
-- are never persisted to ix_characters, so using ix.inventory.New (which
-- inserts an ix_inventories row keyed by character_id) would leak an orphan
-- equipment inventory every time a bot connects. We instead create an
-- in-memory inventory with a synthetic ID well above any realistic MySQL
-- auto-increment or bot SteamID-derived ID, mirroring how the bot's main
-- inventory is created in GM:PlayerInitialSpawn.
local BOT_EQUIP_ID_BASE = 4000000000
nextBotEquipID = nextBotEquipID or BOT_EQUIP_ID_BASE

local function AllocateBotEquipID()
	local id = nextBotEquipID
	nextBotEquipID = nextBotEquipID + 1
	return id
end

function PLUGIN:CharacterLoaded(character)
	local client = character:GetPlayer()
	local index = character:GetEquipID()

	if (index != 0) then
		local inventory = ix.item.inventories[index]

		if (inventory) then
			inventory.vars.isEquipment = true
			inventory:Sync(client)
			inventory:AddReceiver(client)
		else
			ix.inventory.Restore(index, 1, MAX_EQUIPMENT_SLOTS, function(inv)
				inv.vars.isEquipment = true
				inv:Sync(client)
				inv:AddReceiver(client)
			end)
		end
	elseif (character.isBot) then
		-- Bots only exist in memory; never write an ix_inventories row for
		-- them or it leaks an orphan equipment inventory on every connect.
		local botEquipID = AllocateBotEquipID()
		local inv = ix.inventory.Create(1, MAX_EQUIPMENT_SLOTS, botEquipID)

		inv.vars.isEquipment = true
		inv.noSave = true
		inv.owner = character:GetID()

		if (IsValid(client)) then
			inv:AddReceiver(client)
			inv:Sync(client)
		end

		character:SetEquipID(botEquipID)
	elseif (not character.ixCreatingEquip) then
		-- Guard against concurrent equipment-inventory creation. The
		-- SetEquipID call lives inside the async DB callback, so without
		-- this flag a second CharacterLoaded fired before the callback
		-- finished could insert a second ix_inventories row and orphan
		-- every item that had been placed in the first one.
		character.ixCreatingEquip = true

		ix.inventory.New(character:GetID(), "equipment", function(inv)
			inv.vars.isEquipment = true
			inv:Sync(client)
			inv:AddReceiver(client)
			inv:SetOwner(character:GetID(), true)
			character:SetEquipID(inv:GetID())

			character.ixCreatingEquip = nil
		end)
	end

	if (character.outfit) then
		character.outfit = nil
	end

	character.outfit = setmetatable({}, OUTFIT)
	character.outfit:Init(client)

	ReapplyEquipment(character, client)
end

-- On respawn we deliberately do NOT re-run CharacterLoaded. Re-running it
-- would re-enter the equipment creation branch and (because SetEquipID is
-- inside an async callback) could race a second equipment inventory into
-- existence, orphaning everything in the original one. The respawn path
-- only needs to resync the existing inventory and re-apply equipped item
-- effects on the freshly-spawned player.
function PLUGIN:OnPlayerRespawn(client)
	local character = client:GetCharacter()

	if (!character) then return end

	local equipment = character:GetEquipment()

	if (equipment) then
		equipment:AddReceiver(client)
		equipment:Sync(client)
	end

	ReapplyEquipment(character, client)
end

function PLUGIN:PlayerModelChanged(client, model, oldmodel)
	if !client.ChangeModel then client.ChangeModel = true return end

	local character = client:GetCharacter()

	if character then
		if character.outfit then
			character.outfit = nil
		end

		character.outfit = setmetatable({}, OUTFIT)
		character.outfit:Init(client)
	end
end

local function SaveBGCache(client, oldcharacter)
	if oldcharacter then
		local bgs = {}

		for i = 0, (client:GetNumBodyGroups() - 1) do
			bgs[i] = client:GetBodygroup(i)
		end

		oldcharacter:SetData("bgcache", bgs)
	end
end

function PLUGIN:PrePlayerLoadedCharacter(client, character, oldcharacter)
	SaveBGCache(client, oldcharacter)
end

function PLUGIN:PlayerDisconnected(client)
	SaveBGCache(client, client:GetCharacter())
end

-- ix_inventory_audit ---------------------------------------------------------
-- Read-only console command that surfaces the data shapes that historically
-- correlated with vanishing items: items with out-of-range coordinates,
-- equipment rows in non-equipment slot columns, items pointing to deleted
-- inventories, and equipment inventories not referenced by any character.
-- Server console only (IsValid(client) is false there).
local AUDIT_COLOR = Color(255, 200, 0)

local function AuditCount(label, sql)
	mysql:RawQuery(sql, function(result)
		local count = (result and result[1] and tonumber(result[1].count)) or 0
		MsgC(AUDIT_COLOR, string.format("[ix.inventory.audit] %s: %d\n", label, count))
	end)
end

local function AuditSample(label, sql, formatter)
	mysql:RawQuery(sql, function(result)
		if (not istable(result) or #result == 0) then return end

		MsgC(AUDIT_COLOR, string.format("[ix.inventory.audit] %s sample:\n", label))

		for _, row in ipairs(result) do
			MsgC(AUDIT_COLOR, "  " .. formatter(row) .. "\n")
		end
	end)
end

concommand.Add("ix_inventory_audit", function(client)
	if (IsValid(client)) then
		-- Only allow execution from the server console to avoid leaking
		-- internal DB state to in-game admins.
		return
	end

	local maxEquip = MAX_EQUIPMENT_SLOTS or 16

	MsgC(AUDIT_COLOR, "[ix.inventory.audit] starting...\n")

	AuditCount("items with non-positive x/y",
		"SELECT COUNT(*) AS count FROM ix_items WHERE inventory_id != 0 AND (x <= 0 OR y <= 0)")

	AuditCount("equipment items with invalid (x,y)",
		string.format(
			"SELECT COUNT(*) AS count FROM ix_items i " ..
			"INNER JOIN ix_inventories inv ON i.inventory_id = inv.inventory_id " ..
			"WHERE inv.inventory_type = 'equipment' " ..
			"AND (i.x != 1 OR i.y < 1 OR i.y > %d)",
			maxEquip))

	AuditCount("items pointing at non-existent inventories",
		"SELECT COUNT(*) AS count FROM ix_items i " ..
		"LEFT JOIN ix_inventories inv ON i.inventory_id = inv.inventory_id " ..
		"WHERE i.inventory_id != 0 AND inv.inventory_id IS NULL")

	AuditCount("orphan equipment inventories (no character.equipID match)",
		"SELECT COUNT(*) AS count FROM ix_inventories " ..
		"WHERE inventory_type = 'equipment' " ..
		"AND inventory_id NOT IN (SELECT equipID FROM ix_characters " ..
		"WHERE equipID IS NOT NULL AND equipID > 0)")

	AuditSample("items with non-positive x/y",
		"SELECT item_id, inventory_id, unique_id, x, y FROM ix_items " ..
		"WHERE inventory_id != 0 AND (x <= 0 OR y <= 0) LIMIT 10",
		function(row)
			return string.format("item_id=%s inv=%s unique=%s x=%s y=%s",
				tostring(row.item_id), tostring(row.inventory_id),
				tostring(row.unique_id), tostring(row.x), tostring(row.y))
		end)

	AuditSample("equipment items with invalid (x,y)",
		string.format(
			"SELECT i.item_id, i.inventory_id, i.unique_id, i.x, i.y FROM ix_items i " ..
			"INNER JOIN ix_inventories inv ON i.inventory_id = inv.inventory_id " ..
			"WHERE inv.inventory_type = 'equipment' " ..
			"AND (i.x != 1 OR i.y < 1 OR i.y > %d) LIMIT 10",
			maxEquip),
		function(row)
			return string.format("item_id=%s inv=%s unique=%s x=%s y=%s",
				tostring(row.item_id), tostring(row.inventory_id),
				tostring(row.unique_id), tostring(row.x), tostring(row.y))
		end)
end, nil, "Audit ix_items / ix_inventories for inventory data anomalies.")
