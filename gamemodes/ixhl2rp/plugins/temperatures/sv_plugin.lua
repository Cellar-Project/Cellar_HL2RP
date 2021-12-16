local PLUGIN = PLUGIN
PLUGIN.tempMin = -50
PLUGIN.tempMax = 8
PLUGIN.dmgMin = 1
PLUGIN.dmgMax = 21
PLUGIN.offMin = 0.09
PLUGIN.offMax = 21.01

function PLUGIN:ThermalLimbDamage(temperature, client, equipment)
	character = client:GetCharacter()
	local outfit = equipment["torso"].isOutfit
	local dangerous = temperature < 8
	local scale = 1
	if not dangerous then return end


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
	local allDmg = self.dmgMin + self.dmgMax
	local allOff = self.offMin + self.offMax
	local dmg = math.abs(temperature - self.tempMax) * allDmg / (math.abs(self.tempMin) + self.tempMax)
	local offset = math.abs(temperature - self.tempMax) * allOff / (math.abs(self.tempMin) + self.tempMax)
	return {dmg = dmg, offset = offset}
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
	-- todo:
	-- dmg = dmg - isolation * 0.8 (if isolation >= dmg then dmg = 0)
	-- also we should probably do isolation calculation once on equip
	-- to get rid of doing GetItemAtSlot every tick
	-- and write it somewhere in character (SetData? NetVar?)
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
