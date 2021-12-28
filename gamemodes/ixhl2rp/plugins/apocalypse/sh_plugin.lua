local PLUGIN = PLUGIN
PLUGIN.name = "Apocalypse"
PLUGIN.author = "maxxoft"
PLUGIN.description = "The end of times."


if SERVER then
	function PLUGIN:StartApocalypse()
		local players = player.GetAll()

		for _, ply in ipairs(players) do
			self:InfectPlayer(ply)
		end
	end

	function PLUGIN:InfectPlayer(client)
		local character = client:GetCharacter()
		local hasVaccine = character:GetData("hasVaccine", false)

		if not hasVaccine then
			character:SetData("zombie", true)
			character:SetData("zstage", 1)
		end
	end

	function PLUGIN:AdvanceDisease(client)

		if client:GetCharacter():GetData("zstage") == 3 then
			local items = character:GetInventory():GetItemsByBase("base_weaponstest", true)

			for _, item in pairs(items) do
				if isfunction(item.Unequip) then
					item:Unequip(character)
				end
			end
		end
	end
end
