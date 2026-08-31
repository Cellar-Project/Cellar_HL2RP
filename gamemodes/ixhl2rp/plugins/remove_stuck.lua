local PLUGIN = PLUGIN

PLUGIN.name = "Remove Stuck Items"
PLUGIN.author = "maxxoft"
PLUGIN.description = "Lets admins permanently remove nearby item entities that are stuck under the map."

local ACCESS_PRIVILEGE = "Helix - Bypass Prop Protection"
local SEARCH_RADIUS = 1024

if (SERVER) then
	util.AddNetworkString("ixRemoveStuckOpen")
	util.AddNetworkString("ixRemoveStuckConfirm")

	ix.log.AddType("removeStuck", function(client, ...)
		local args = {...}
		return string.format("%s permanently removed stuck item '%s' (#%s).",
			client:Name(), tostring(args[1] or "?"), tostring(args[2] or "?"))
	end)

	local function GetItemName(entity, itemTable)
		if (itemTable and itemTable.GetName) then
			local ok, name = pcall(itemTable.GetName, itemTable)

			if (ok and isstring(name) and name != "") then
				return name
			end
		end

		return entity:GetItemID() or "Unknown Item"
	end

	local function CollectNearbyItems(client)
		local origin = client:GetPos()
		local items = {}

		for _, entity in ipairs(ents.FindByClass("ix_item")) do
			if (IsValid(entity)) then
				local distance = entity:GetPos():Distance(origin)

				if (distance <= SEARCH_RADIUS) then
					local itemTable = entity:GetItemTable()

					items[#items + 1] = {
						index = entity:EntIndex(),
						itemID = entity.ixItemID or 0,
						uniqueID = (itemTable and itemTable.uniqueID) or entity:GetItemID() or "?",
						name = tostring(GetItemName(entity, itemTable)),
						distance = math.Round(distance),
					}
				end
			end
		end

		table.sort(items, function(a, b)
			return a.distance < b.distance
		end)

		return items
	end

	local function SendList(client)
		local items = CollectNearbyItems(client)

		net.Start("ixRemoveStuckOpen")
			net.WriteUInt(#items, 16)

			for _, info in ipairs(items) do
				net.WriteUInt(info.index, 16)
				net.WriteUInt(info.itemID, 32)
				net.WriteString(info.uniqueID)
				net.WriteString(info.name)
				net.WriteUInt(info.distance, 16)
			end
		net.Send(client)
	end

	net.Receive("ixRemoveStuckConfirm", function(length, client)
		if (!CAMI.PlayerHasAccess(client, ACCESS_PRIVILEGE, nil)) then
			return
		end

		local entIndex = net.ReadUInt(16)
		local entity = Entity(entIndex)

		if (!IsValid(entity) or entity:GetClass() != "ix_item") then
			client:Notify("That item entity is no longer valid.")
			return
		end

		local itemTable = entity:GetItemTable()
		local itemID = entity.ixItemID or 0
		local name = GetItemName(entity, itemTable)
		local instance = ix.item.instances[itemID]

		ix.log.Add(client, "removeStuck", name, itemID)
		client:Notify(string.format("Permanently removed item '%s' (#%s).", tostring(name), tostring(itemID)))

		if (instance and instance.Remove) then
			instance:Remove()
		else
			entity:Remove()
		end
	end)

	ix.command.Add("RemoveStuck", {
		description = "Brings up a list of nearby items so you can permanently remove one stuck under the map.",
		OnCheckAccess = function(self, client)
			return CAMI.PlayerHasAccess(client, ACCESS_PRIVILEGE, nil)
		end,
		OnRun = function(self, client)
			SendList(client)
		end,
	})
else
	ix.command.Add("RemoveStuck", {
		description = "Brings up a list of nearby items so you can permanently remove one stuck under the map.",
		OnCheckAccess = function(self, client)
			return CAMI.PlayerHasAccess(client, ACCESS_PRIVILEGE, nil)
		end,
		OnRun = function(self, client)
			return true -- Let the server handle it and open the menu via net message
		end,
	})
	local activePanel

	local function OpenList(items)
		if (IsValid(activePanel)) then
			activePanel:Remove()
		end

		local frame = vgui.Create("DFrame")
		frame:SetSize(580, 420)
		frame:Center()
		frame:SetTitle("Remove Stuck Items (" .. #items .. " within " .. SEARCH_RADIUS .. " units)")
		frame:SetDeleteOnClose(true)
		frame:MakePopup()

		local list = vgui.Create("DListView", frame)
		list:Dock(FILL)
		list:DockMargin(0, 0, 0, 4)
		list:SetMultiSelect(false)
		list:AddColumn("Name"):SetFixedWidth(240)
		list:AddColumn("Unique ID"):SetFixedWidth(160)
		list:AddColumn("Item ID"):SetFixedWidth(70)
		list:AddColumn("Distance"):SetFixedWidth(80)

		for _, info in ipairs(items) do
			local line = list:AddLine(info.name, info.uniqueID, info.itemID, info.distance)
			line.entIndex = info.index
			line.itemName = info.name
			line.itemID = info.itemID
		end

		local removeBtn = vgui.Create("DButton", frame)
		removeBtn:Dock(BOTTOM)
		removeBtn:SetTall(32)
		removeBtn:SetText("Permanently Remove Selected")
		removeBtn.DoClick = function()
			local selectedIndex = list:GetSelectedLine()

			if (!selectedIndex) then
				Derma_Message("Select an item from the list first.", "No Selection", "OK")
				return
			end

			local row = list:GetLine(selectedIndex)

			if (!row) then
				return
			end

			Derma_Query(
				string.format("Permanently remove '%s' (#%s)?\nThis cannot be undone.",
					tostring(row.itemName or "?"), tostring(row.itemID or "?")),
				"Confirm Removal",
				"Yes", function()
					net.Start("ixRemoveStuckConfirm")
						net.WriteUInt(row.entIndex, 16)
					net.SendToServer()

					list:RemoveLine(selectedIndex)
				end,
				"No", function() end
			)
		end

		activePanel = frame
	end

	net.Receive("ixRemoveStuckOpen", function()
		local count = net.ReadUInt(16)
		local items = {}

		for i = 1, count do
			items[i] = {
				index = net.ReadUInt(16),
				itemID = net.ReadUInt(32),
				uniqueID = net.ReadString(),
				name = net.ReadString(),
				distance = net.ReadUInt(16),
			}
		end

		if (#items == 0) then
			chat.AddText(Color(255, 200, 80), "[Remove Stuck] ",
				Color(255, 255, 255), "No item entities within " .. SEARCH_RADIUS .. " units.")
			return
		end

		OpenList(items)
	end)
end
