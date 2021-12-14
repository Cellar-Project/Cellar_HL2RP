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
				character:AddShockDamage(damage * 10)
			end
		end
	end

	-- TODO: all the other limbs
end

function PLUGIN:GetTempDamage(temperature)
	local tempToDamage = {
		[8] = {dmg = 1, offset = 0.09},
		[0] = {dmg = 2, offset = 0.1},
		[-8] = {dmg = 4, offset = 0.3},
		[-15] = {dmg = 8, offset = 0.7},
		[-25] = {dmg = 12, offset = 0.9},
		[-35] = {dmg = 17, offset = 1.1},
		[-50] = {dmg = 21, offset = 2.01}
	}
	local index = 8

	for temp, tab in pairs(tempToDamage) do
		if math.abs(temperature - index) > math.abs(temperature - temp) then
			index = temp
		end
	end

	return tempToDamage[index]
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
