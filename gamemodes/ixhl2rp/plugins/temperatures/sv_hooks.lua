local PLUGIN = PLUGIN


function PLUGIN:OnPlayerAreaChanged(client, oldID, newID)
	-- local area = ix.area.stored[newID]
	-- local temp = area.properties.temperature

	-- adjust timer maybe? or remove func?
end

function PLUGIN:SetupTempTimer(client)
	local uniqueID = "ixTemp" .. client:SteamID()
	timer.Remove(uniqueID)

	local character = client:GetCharacter()
	if character then
		local faction = ix.faction.indices[character:GetFaction()]

		if faction.tempImmunity then
			return
		end
	end

	timer.Create(uniqueID, ix.config.Get("tempTickTime", 4), 0, function()
		if !IsValid(client) then
			timer.Remove(uniqueID)
			return
		end

		self:TempTick(client)
	end)
end
