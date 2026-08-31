
util.AddNetworkString("ixInventoryFlipItem")

do
	local ITEM = ix.meta.item

	local function CanRemainOnSamePos(inventory, x, y, w, h)
		local bCanRemain = true

		for x2 = 0, w - 1 do
			for y2 = 0, h - 1 do
				local item = (inventory.slots[x + x2] or {})[y + y2]

				if ((x + x2) > inventory.w or (y + y2) > inventory.h or item) then
					bCanRemain = false

					break
				end
			end

			if (!bCanRemain) then
				break
			end
		end

		return bCanRemain
	end

	function ITEM:Flip(bNoReplication, bNoSave)
		local failureMessage

		if (self.width != self.height) then
			local inventory = ix.item.inventories[self.invID]

			if (self.invID > 0 and inventory) then
				failureMessage = "unknownError"
				local bSlotsBroken = false

				for x2 = self.gridX, self.gridX + (self.width - 1) do
					if (inventory.slots[x2]) then
						for y2 = self.gridY, self.gridY + (self.height - 1) do
							local slotItem = inventory.slots[x2][y2]

							if (slotItem and self.id == slotItem.id) then
								inventory.slots[x2][y2] = nil
							else
								bSlotsBroken = true
							end
						end
					end
				end

				if (!bSlotsBroken) then
					failureMessage = "noFit"
					local fWidth, fHeight = ix.item.RawFlip(self, true)
					local x, y = self.gridX, self.gridY
					local bCanItemFit = CanRemainOnSamePos(inventory, x, y, fWidth, fHeight)

					if (!bCanItemFit) then
						x, y = inventory:FindEmptySlot(fWidth, fHeight, true)
					end

					if (x and y) then
						local oldX, oldY = self.gridX, self.gridY

						inventory.slots[x] = inventory.slots[x] or {}
						inventory.slots[x][y] = true

						self.width = fWidth
						self.height = fHeight
						self.gridX = x
						self.gridY = y

						for x2 = 0, self.width - 1 do
							local index = x + x2

							for y2 = 0, self.height - 1 do
								inventory.slots[index] = inventory.slots[index] or {}
								inventory.slots[index][y + y2] = self
							end
						end

						self:SetData("flip", !self.data["flip"], nil, bNoSave)

						if (!bNoReplication) then
							local receivers = inventory:GetReceivers()

							if (!table.IsEmpty(receivers)) then
								net.Start("ixInventoryFlipItem")
									net.WriteUInt(inventory:GetID(), 32)
									net.WriteUInt(oldX, 6)
									net.WriteUInt(oldY, 6)
									net.WriteUInt(x, 6)
									net.WriteUInt(y, 6)
									net.WriteString(self.uniqueID)
									net.WriteUInt(self.id, 32)
									net.WriteUInt(inventory.owner or 0, 32)
								net.Send(receivers)
							end
						end

						if (!bNoSave) then
							local query = mysql:Update("ix_items")
								query:Update("x", x)
								query:Update("y", y)
								query:WhereNotEqual("x", x)
								query:WhereNotEqual("y", y)
								query:Where("item_id", self.id)
							query:Execute()
						end

						return true
					end
				end

				for x2 = self.gridX, self.gridX + (self.width - 1) do
					inventory.slots[x2] = inventory.slots[x2] or {}

					for y2 = self.gridY, self.gridY + (self.height - 1) do
						local slotItem = inventory.slots[x2][y2]

						if (!slotItem) then
							inventory.slots[x2][y2] = self
						end
					end
				end
			end
		end

		return false, failureMessage
	end
end

net.Receive("ixInventoryFlipItem", function(_, client)
	local realTime = RealTime()

	if ((client.ixNextItemFlip or 0) <= realTime) then
		local character = client:GetCharacter()

		if (character) then
			local itemID = net.ReadUInt(32)
			local invID = net.ReadUInt(32)
			local inventory = ix.item.inventories[invID]

			if (inventory and inventory:OnCheckAccess(client)) then
				local item = ix.item.instances[itemID]

				if (item and invID == item.invID) then
					local result, message = item:Flip()

					if (!result and message) then
						client:NotifyLocalized(message)
					end
				end
			end
		end

		client.ixNextItemFlip = realTime + 0.5
	end
end)

-- OVERRIDE --

-- swaping items instances width and height if they are flipped and thus making sure they're attached to correct inventory slots
ix.inventory = ix.inventory or {}

local INV_LOG_COLOR = Color(255, 200, 0)

-- Mirrors META:FindEmptySlot but operates on a passed-in slot table because
-- during Restore the inventory's own slots haven't been swapped in yet (they
-- live in a local invSlots[invID] map until the end of the callback).
local function FindEmptySlotInLocalSlots(slots, invW, invH, w, h)
	w = w or 1
	h = h or 1

	if (w > invW or h > invH) then
		return
	end

	for y = 1, invH - (h - 1) do
		for x = 1, invW - (w - 1) do
			local canFit = true

			for x2 = 0, w - 1 do
				for y2 = 0, h - 1 do
					if ((slots[x + x2] or {})[y + y2]) then
						canFit = false
						break
					end
				end

				if (!canFit) then break end
			end

			if (canFit) then
				return x, y
			end
		end
	end
end

function ix.inventory.Restore(invID, width, height, callback)
	local inventories = {}

	if (!istable(invID)) then
		if (!isnumber(invID) or invID < 0) then
			error("Attempt to restore inventory with an invalid ID!")
		end

		inventories[invID] = {width, height}
		ix.inventory.Create(width, height, invID)
	else
		for k, v in pairs(invID) do
			inventories[k] = {v[1], v[2], v[3]}

			local inv = ix.inventory.Create(v[1], v[2], k)

			-- Set the equipment flag synchronously, so any Add/Move that runs
			-- during the async restore window targets the right slot column
			-- instead of treating equipment as a generic grid.
			if (inv and v[3] == "equipment") then
				inv.vars.isEquipment = true
			end
		end
	end

	local query = mysql:Select("ix_items")
		query:Select("item_id")
		query:Select("inventory_id")
		query:Select("unique_id")
		query:Select("data")
		query:Select("character_id")
		query:Select("player_id")
		query:Select("x")
		query:Select("y")
		query:WhereIn("inventory_id", table.GetKeys(inventories))
		query:Callback(function(result)
			if (istable(result) and #result > 0) then
				local invSlots = {}
				local repairs = {}

				for _, item in ipairs(result) do
					local itemInvID = tonumber(item.inventory_id)
					local invInfo = inventories[itemInvID]

					if (!itemInvID or !invInfo) then
						-- don't restore items with an invalid inventory id or type
						continue
					end

					local inventory = ix.item.inventories[itemInvID]
					local x, y = tonumber(item.x), tonumber(item.y)
					local itemID = tonumber(item.item_id)
					local data = util.JSONToTable(item.data or "[]")
					local characterID, playerID = tonumber(item.character_id), tostring(item.player_id)

					if (!itemID) then
						continue
					end

					local item2 = ix.item.New(item.unique_id, itemID)

					if (!item2) then
						continue
					end

					invSlots[itemInvID] = invSlots[itemInvID] or {}
					local slots = invSlots[itemInvID]

					item2.data = {}

					if (data) then
						item2.data = data

						if (item2.data["flip"]) then
							ix.item.RawFlip(item2)
						end
					end

					-- Sanitize coordinates: if they're missing or fall outside the
					-- inventory grid, relocate the item instead of silently dropping
					-- it. Historically this skip-on-out-of-range path was the main
					-- source of items "disappearing" on relog / server restart.
					--
					-- Equipment vs. generic inventories are handled differently:
					--   * generic grids: item occupies item.width x item.height cells
					--     starting at (gridX, gridY), so we bounds-check the full
					--     footprint and relocate via FindEmptySlot when broken.
					--   * equipment: each item lives in exactly ONE cell of the
					--     single 1-wide column, keyed by item.slot (HEAD/TORSO/...).
					--     item.width/height are visual hints only; using them as
					--     bounds incorrectly invalidates every multi-cell outfit.
					local w = item2.width or 1
					local h = item2.height or 1
					local origX, origY = x, y
					local isEquipInv = inventory.vars and inventory.vars.isEquipment

					if (isEquipInv) then
						-- Equipment is always x=1 and y is the slot index.
						x = 1

						local stockItem = ix.item.list[item2.uniqueID]
						local correctSlot = stockItem and stockItem.slot

						-- Self-heal: an equipment item can only ever live in its
						-- declared slot, so if y has drifted (e.g. from an earlier
						-- buggy restore) move it back to item.slot, but only if
						-- the target slot isn't already taken by a different item.
						if (correctSlot and correctSlot > 0 and correctSlot <= inventory.h
							and y ~= correctSlot) then
							local existing = slots[1] and slots[1][correctSlot]

							if (not existing or existing == true or
								(istable(existing) and existing.id == item2.id)) then
								y = correctSlot
							end
						end

						if (not y or y < 1 or y > inventory.h) then
							-- y is still bad and no item.slot was usable; fall back
							-- to slot 1 so the item remains visible.
							y = 1
						end

						if (x ~= origX or y ~= origY) then
							repairs[#repairs + 1] = {
								itemID = itemID,
								uniqueID = item2.uniqueID,
								invID = itemInvID,
								origX = origX, origY = origY,
								newX = x, newY = y,
							}
						end
					else
						if (!x or !y or x <= 0 or y <= 0
							or (x + w - 1) > inventory.w or (y + h - 1) > inventory.h) then
							local newX, newY = FindEmptySlotInLocalSlots(slots, inventory.w, inventory.h, w, h)

							if (newX and newY) then
								x, y = newX, newY
							else
								-- Inventory has no room for the original footprint;
								-- fall back to (1,1) so the item is at least visible.
								x, y = 1, 1
							end

							repairs[#repairs + 1] = {
								itemID = itemID,
								uniqueID = item2.uniqueID,
								invID = itemInvID,
								origX = origX, origY = origY,
								newX = x, newY = y,
							}
						end
					end

					item2.gridX = x
					item2.gridY = y
					item2.invID = itemInvID
					item2.characterID = characterID
					item2.playerID = (playerID == "" or playerID == "NULL") and nil or playerID

					if (isEquipInv) then
						-- Equipment: single cell at slots[1][y].
						slots[1] = slots[1] or {}
						slots[1][y] = item2
					else
						for x2 = 0, w - 1 do
							for y2 = 0, h - 1 do
								slots[x + x2] = slots[x + x2] or {}
								slots[x + x2][y + y2] = item2
							end
						end
					end

					if (item2.OnRestored) then
						item2:OnRestored(item2, itemInvID)
					end
				end

				for k, v in pairs(invSlots) do
					ix.item.inventories[k].slots = v
				end

				-- Persist any repaired coordinates back to the DB so the same
				-- row doesn't have to be relocated on every subsequent restore.
				for _, repair in ipairs(repairs) do
					MsgC(INV_LOG_COLOR, string.format(
						"[ix.inventory] Repaired item #%d (%s) in inv %d: (%s,%s) -> (%d,%d)\n",
						repair.itemID, tostring(repair.uniqueID), repair.invID,
						tostring(repair.origX), tostring(repair.origY),
						repair.newX, repair.newY
					))

					local upd = mysql:Update("ix_items")
						upd:Update("x", repair.newX)
						upd:Update("y", repair.newY)
						upd:Where("item_id", repair.itemID)
					upd:Execute()
				end
			end

			if (callback) then
				for k, _ in pairs(inventories) do
					callback(ix.item.inventories[k])
				end
			end
		end)
	query:Execute()
end
