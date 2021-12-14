local PLUGIN = PLUGIN


function PLUGIN:ThermalLimbDamage(temperature, client, equipment)
	character = client:GetCharacter()
	local outfit = equipment["torso"].isOutfit
	local dangerous = temperature < 8
	local scale = 1


	-- calculate damage through outfit:
	if outfit then
		local resist = equipment["torso"].thermalIsolation -- * 0.01 or 0
		local damage

		if not positive then
			print("scale = " .. scale)
			print("resist = " .. resist)
			print("temperature = " .. temperature)
			damage = resist - (temperature / scale)
			print("damage = " .. tostring(damage))
			if damage > 0 then
				print("TakeOverallLimbDamage")
				character:TakeOverallLimbDamage(damage)
				character:AddShockDamage(damage * 5)
			end
		end
	end

	-- TODO: all the other limbs
end

function PLUGIN:GetTempDamage(temperature)

end

function PLUGIN:CalculateThermalDamage(temperature, client)
	if not client.ixInArea then return end
	if temperature >= 0 and temperature <= 29 then return end

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
	local area = ix.area.stored[client.ixArea]
	print("TempTick")
	if area then
		PrintTable(area)
		local temperature = area.properties.temperature
		self:CalculateThermalDamage(temperature, client)
	end
end
