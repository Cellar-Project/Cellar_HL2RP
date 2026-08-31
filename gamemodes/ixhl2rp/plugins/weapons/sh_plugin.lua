PLUGIN.name = "Ammo and Weapons"
PLUGIN.description = "Stackable ammunition and equipable weapon items for Cellar HL2RP."
PLUGIN.author = "SchwarzKruppzo, maxxoft"
PLUGIN.version = "1.0.0"

-- Strip equipped weapons and clear ammo on player death.
hook.Add("PlayerDeath", "ixStripClip", function(client)
	if not IsValid(client) or not client:GetCharacter() then
		return
	end

	client.carryWeapons = {}

	local inventory = client:GetCharacter():GetInventory()
	if not inventory then
		return
	end

	for _, v in pairs(inventory:GetItems()) do
		if v.isWeapon and v:GetData("equip") then
			v:SetData("ammo", nil)
			v:SetData("equip", nil)

			if v.pacData then
				v:RemovePAC(client)
			end
		end
	end
end)
