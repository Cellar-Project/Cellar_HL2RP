function ix.item.Load(path, baseID, isBaseItem)
	local l, uniqueID = path:match("sh_(!*)([_%w]+)%.lua")
	
	if (uniqueID) then
		uniqueID = (isBaseItem and "base_" or "")..uniqueID
		if l == "!" then
			ix.util.Include(path)
		else
			ix.item.Register(uniqueID, baseID, isBaseItem, path)
		end
	else
		if (!path:find(".txt")) then
			ErrorNoHalt("[Helix] Item at '"..path.."' follows invalid naming convention!\n")
		end
	end
end

function ix.item.New2(baseID, isBaseItem)
	local ITEM = setmetatable({}, ix.meta.item)
	ITEM.base = baseID or ITEM.base
	ITEM.isBase = isBaseItem or false
	ITEM.hooks = ITEM.hooks or {}
	ITEM.postHooks = ITEM.postHooks or {}
	ITEM.functions = ITEM.functions or {}
	ITEM.functions.drop = ITEM.functions.drop or {
		tip = "dropTip",
		icon = "icon16/world.png",
		OnRun = function(item)
			local bSuccess, error = item:Transfer(nil, nil, nil, item.player)

			if (!bSuccess and isstring(error)) then
				item.player:NotifyLocalized(error)
			else
				item.player:EmitSound("npc/zombie/foot_slide" .. math.random(1, 3) .. ".wav", 75, math.random(90, 120), 1)
			end

			return false
		end,
		OnCanRun = function(item)
			return !IsValid(item.entity) and !item.noDrop
		end
	}
	ITEM.functions.take = ITEM.functions.take or {
		tip = "takeTip",
		icon = "icon16/box.png",
		OnRun = function(item)
			local client = item.player
			local bSuccess, error = item:Transfer(client:GetCharacter():GetInventory():GetID(), nil, nil, client)

			if (!bSuccess) then
				client:NotifyLocalized(error or "unknownError")
				return false
			else
				client:EmitSound("npc/zombie/foot_slide" .. math.random(1, 3) .. ".wav", 75, math.random(90, 120), 1)

				if (item.data) then -- I don't like it but, meh...
					for k, v in pairs(item.data) do
						item:SetData(k, v)
					end
				end
			end

			return true
		end,
		OnCanRun = function(item)
			return IsValid(item.entity)
		end
	}

	ITEM = ix.item.ApplyBase2(ITEM)

	if (PLUGIN) then
		ITEM.plugin = PLUGIN.uniqueID
	end

	return ITEM
end

-- Merges the base referenced by ITEM.base into ITEM and records it in
-- ITEM.baseTable so later calls can tell whether the base has changed.
function ix.item.ApplyBase2(ITEM)
	if (!ITEM.base) then
		return ITEM
	end

	local baseTable = ix.item.base[ITEM.base]

	if (!baseTable) then
		ErrorNoHalt("[Helix] Item '"..tostring(ITEM.uniqueID or ITEM.name).."' has a non-existent base! ("..ITEM.base..")\n")
		return ITEM
	end

	if (ITEM.baseTable == baseTable) then
		return ITEM
	end

	local mergeTable = table.Copy(baseTable)
	ITEM = table.Merge(mergeTable, ITEM)
	ITEM.baseTable = baseTable

	return ITEM
end

function ix.item.Register2(ITEM)
	if (ITEM) then
		local uniqueID = string.lower(string.gsub(string.gsub(ITEM.name, "%s", "_"), "['%.]", ""))
		uniqueID = (ITEM.isBase and "base_" or "")..uniqueID

		ITEM.uniqueID = uniqueID
		ITEM = ix.item.ApplyBase2(ITEM)

		ITEM.description = ITEM.description or "noDesc"
		ITEM.width = ITEM.width or 1
		ITEM.height = ITEM.height or 1
		ITEM.category = ITEM.category or "misc"

		if (ITEM.OnRegistered) then
			ITEM:OnRegistered()
		end

		(ITEM.isBase and ix.item.base or ix.item.list)[ITEM.uniqueID] = ITEM

		if (IX_RELOADED) then
			-- we don't know which item was actually edited, so we'll refresh all of them
			for _, v in pairs(ix.item.instances) do
				if (v.uniqueID == uniqueID) then
					table.Merge(v, ITEM)
				end
			end
		end

		return ITEM
	else
		ErrorNoHalt("[Helix] You tried to register an invalid item!\n")
	end
end
