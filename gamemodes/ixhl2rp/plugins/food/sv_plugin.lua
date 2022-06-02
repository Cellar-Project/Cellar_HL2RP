
util.AddNetworkString("ixFoodConservation")

function PLUGIN:OnItemTransferred(item, oldInv, newInv)
	local osTime = os.time()
	local expirationDate = item:GetData("expirationDate")

	if (isnumber(expirationDate) and expirationDate > osTime) then
		local containerEntity
		local dateToSet
		local timeLeftToSet

		if (newInv.vars and newInv.vars.isContainer) then
			containerEntity = newInv.storageInfo.entity
			dateToSet = expirationDate + 2629744 -- month
			timeLeftToSet = expirationDate - osTime
		elseif (oldInv.vars and oldInv.vars.isContainer) then
			local expirationTimeLeft = item:GetData("expirationTimeLeft")

			containerEntity = oldInv.storageInfo.entity
			dateToSet = expirationTimeLeft and osTime + expirationTimeLeft or expirationDate
		else
			return
		end

		if (ix.container.stored[containerEntity:GetModel()].bRefrigerator) then
			item:SetData("expirationDate", dateToSet)
			item:SetData("expirationTimeLeft", timeLeftToSet)

			-- the owner has changed so we have to network info like this
			net.Start("ixFoodConservation")
				net.WriteUInt(item:GetID(), 32)
				net.WriteUInt(dateToSet, 32)
				if (timeLeftToSet) then net.WriteUInt(timeLeftToSet, 32) end
			net.Broadcast()
		end
	end
end

-- func to freeze existing items in refrigerators
--[[
for k, v in ipairs(ents.FindByClass("ix_container")) do
	if (ix.container.stored[v:GetModel()].bRefrigerator) then
		local inventory = ix.item.inventories[v:GetID()]

		if (inventory) then
			local items = inventory:GetItems()

			for _, v2 in pairs(items) do
				local expirationDate = v2:GetData("expirationDate")

				if (expirationDate and !v2:GetData("expirationTimeLeft")) then
					local dateToSet = expirationDate + 2629744 -- month
					local timeLeftToSet = expirationDate - os.time()

					v2:SetData("expirationDate", dateToSet)
					v2:SetData("expirationTimeLeft", timeLeftToSet)
				end
			end
		end
	end
end
]]
