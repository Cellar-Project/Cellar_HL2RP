local PLUGIN = PLUGIN

PLUGIN.name = "Apocalypse"
PLUGIN.author = "maxxoft"
PLUGIN.description = "The end of times."


if SERVER then
	PLUGIN.models = {
		[""] = ""
	}

	function PLUGIN:StartApocalypse()
		local players = player.GetAll()

		for _, ply in ipairs(players) do
			self:InfectPlayer(ply)
		end
	end

	function PLUGIN:InfectPlayer(client)
		if client:IsOTA() then return end
		local character = client:GetCharacter()
		local hasVaccine = character:GetData("hasVaccine", false)

		if not hasVaccine then
			character:SetData("zombie", true)
			character:SetData("zstage", 1)
		end
	end

	function PLUGIN:AdvanceDisease(client)
		local char = client:GetCharacter()
		local stage = char:GetData("zstage", 0)

		char:SetData("zstage", math.Clamp(stage + 1, 0, 3))

		if char:GetData("zstage") == 3 then
			local items = character:GetInventory():GetItemsByBase("base_weaponstest", true)

			for _, item in pairs(items) do
				if isfunction(item.Unequip) then
					item:Unequip(character)
				end
			end

			char:SetModel(self.models[char:GetModel()] or table.Random(self.models))
		end
	end
end
