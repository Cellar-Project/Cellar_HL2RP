local PLUGIN = PLUGIN



function PLUGIN:ThermalLimbDamage(temperature, client, equipment)
	local outfit = equipment["torso"].isOutfit
	local positive = temperature > 0
	local scale = 4
	if not positive then scale = -scale end -- I'm not a mathematician, sorry

	-- calculate damage through outfit:
	if outfit then
		local resist = equipment["torso"].thermalIsolation * 0.01 or 0
		local damage

		if not positive then
			damage = resist - (temperature / scale)
			if damage > 0 then
				character:TakeOverallLimbDamage(damage)
			end
		end
	end

	-- TODO: all the other limbs
end

function PLUGIN:CalculateThermalDamage(temperature, client)
	if not client.ixArea then return end
	if 20 <= temperature <= 29 then return end

	local positive = temperature > 0
	local character = client:GetCharacter()
	local inventory = character:GetEquipment()
	local equipment = {
		["head"] = inventory:GetItemAtSlot(EQUIP_HEAD),
		["torso"] = inventory:GetItemAtSlot(EQUIP_TORSO),
		["hands"] = inventory:GetItemAtSlot(EQUIP_HANDS),
		["legs"] = inventory:GetItemAtSlot(EQUIP_LEGS)
	}

	self:ThermalLimbDamage(temperature, client, equipment)
end

function PLUGIN:TempTick(client)
	if not client.ixArea then return end

	local temperature = client.ixArea.properties.temperature

	self:CalculateThermalDamage(temperature, client)
end
