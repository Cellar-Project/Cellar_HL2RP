local PLUGIN = PLUGIN

PLUGIN.name = "Dynamic hands"
PLUGIN.description = "Dynamic hands change depending on character's outfit."
PLUGIN.author = "maxxoft"

if SERVER then

	PLUGIN.CombineModels = {
		"models/cellar/characters/metropolice/female/cca_female_01.mdl",
		"models/cellar/characters/metropolice/female/cca_female_02.mdl",
		"models/cellar/characters/metropolice/female/cca_female_03.mdl",
		"models/cellar/characters/metropolice/female/cca_female_04.mdl",
		"models/cellar/characters/metropolice/female/cca_female_05.mdl",
		"models/cellar/characters/metropolice/female/cca_female_06.mdl",
		"models/cellar/characters/metropolice/female/cca_female_07.mdl",
		"models/cellar/characters/metropolice/female/cca_female_08.mdl",
		"models/cellar/characters/metropolice/female/cca_female_09.mdl",
		"models/cellar/characters/metropolice/female/cca_female_10.mdl",
		"models/cellar/characters/metropolice/female/cca_female_12.mdl",
		"models/cellar/characters/metropolice/female/cca_female_13.mdl",
		"models/cellar/characters/metropolice/female/cca_female_14.mdl",
		"models/cellar/characters/metropolice/female/cca_female_15.mdl",
		"models/cellar/characters/metropolice/female/cca_female_16.mdl",
		"models/cellar/characters/metropolice/female/cca_female_17.mdl",
		"models/cellar/characters/metropolice/female/cca_female_18.mdl",
		"models/cellar/characters/metropolice/male/cca_male_01.mdl",
		"models/cellar/characters/metropolice/male/cca_male_02.mdl",
		"models/cellar/characters/metropolice/male/cca_male_03.mdl",
		"models/cellar/characters/metropolice/male/cca_male_04.mdl",
		"models/cellar/characters/metropolice/male/cca_male_05.mdl",
		"models/cellar/characters/metropolice/male/cca_male_06.mdl",
		"models/cellar/characters/metropolice/male/cca_male_07.mdl",
		"models/cellar/characters/metropolice/male/cca_male_08.mdl",
		"models/cellar/characters/metropolice/male/cca_male_09.mdl",
		"models/cellar/characters/metropolice/male/cca_male_10.mdl",
		"models/cellar/characters/metropolice/male/cca_male_11.mdl",
		"models/cellar/characters/metropolice/male/cca_male_12.mdl",
		"models/cellar/characters/metropolice/male/cca_male_13.mdl",
		"models/cellar/characters/metropolice/male/cca_male_14.mdl",
		"models/cellar/characters/metropolice/male/cca_male_15.mdl",
		"models/cellar/characters/metropolice/male/cca_male_16.mdl",
		"models/cellar/characters/metropolice/male/cca_male_17.mdl",
		"models/cellar/characters/metropolice/male/cca_male_18.mdl",
		"models/cellar/characters/combine/soldier_male.mdl",
		"models/cellar/characters/combine/soldier_female.mdl",
		"models/cellar/characters/combine/elite_male.mdl",
		"models/cellar/characters/combine/elite_female.mdl"
	}
	PLUGIN.ZombieModels = {
		"models/corrupt/zombie_03.mdl",
		"models/corrupt/zombie_02.mdl",
		"models/corrupt/zombie_01.mdl",
		"models/freshdead/freshdead_01.mdl",
		"models/freshdead/freshdead_02.mdl",
		"models/freshdead/freshdead_03.mdl",
		"models/freshdead/freshdead_04.mdl",
		"models/freshdead/freshdead_05.mdl",
		"models/freshdead/freshdead_06.mdl",
		"models/freshdead/freshdead_07.mdl",
		"models/zombie/grabber_01.mdl",
		"models/zombie/grabber_02.mdl",
		"models/zombie/grabber_03.mdl",
		"models/zombie/grabber_04.mdl",
		"models/zombie/grabber_05.mdl",
		"models/zombie/grabber_06.mdl",
		"models/zombie/grabber_07.mdl",
		"models/zombie/grabber_08.mdl",
		"models/zombie/grabber_09.mdl",
		"models/cpassic/cpassic.mdl"
	}

	do
		for k, model in ipairs(PLUGIN.CombineModels) do
			local shortname = string.Explode("/", model) -- wtf is this? debug it later
			player_manager.AddValidModel(shortname, model)
			player_manager.AddValidHands(shortname, "models/weapons/c_arms_combine.mdl", 1, "0000000")
		end

		for k, model in ipairs(PLUGIN.ZombieModels) do
			local shortname = string.Explode("/", model)
			player_manager.AddValidModel(shortname, model)
			player_manager.AddValidHands(shortname, "models/weapons/c_arms_citizen.mdl", 1, "0000000")
		end
	end

	function PLUGIN:PlayerLoadedCharacter(client, character, lastchar)
		timer.Simple(3, function()
			character:SetData("mdl_ld", false)
			hook.Run("PlayerSetHandsModel", client, client:GetHands())
		end)
	end

	function PLUGIN:PlayerModelChanged(client, model, lastmodel)
		timer.Simple(2, function()
			if !isfunction(client.GetCharacter) then return end
			local char = client:GetCharacter()
			if char and char:GetData("mdl_ld") and IsValid(client:GetHands()) then
				hook.Run("PlayerSetHandsModel", client, client:GetHands())
			else
				if char and isfunction(char.SetData) then char:SetData("mdl_ld", true) end
				return
			end
		end)
	end
end