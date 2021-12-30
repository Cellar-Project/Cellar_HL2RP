local PLUGIN = PLUGIN

PLUGIN.name = "Apocalypse"
PLUGIN.author = "maxxoft"
PLUGIN.description = "The end of times."


ix.command.Add("StartApocalypse", {
	description = "Start the apocalypse.",
	superAdminOnly = true,
	OnRun = function(self, client)
		PLUGIN:StartApocalypse()
	end
})

ix.command.Add("CharInfect", {
	description = "Infect the character.",
	superAdminOnly = true,
	arguments = ix.type.character,
	OnRun = function(self, client, character)
		PLUGIN:InfectCharacter(character)
	end
})

ix.command.Add("ZAdvance", {
	description = "Advance character's disease.",
	superAdminOnly = true,
	arguments = ix.type.character,
	OnRun = function(self, client, character)
		PLUGIN:AdvanceDisease(character)
	end
})

if SERVER then
	PLUGIN.models = {
		["models/cellar/characters/oldcitizens/female_01.mdl"] = "models/freshdead/freshdead_05.mdl",
		["models/cellar/characters/oldcitizens/female_02.mdl"] = "models/freshdead/freshdead_06.mdl",
		["models/cellar/characters/oldcitizens/female_03.mdl"] = "models/freshdead/freshdead_07.mdl",
		["models/cellar/characters/oldcitizens/female_04.mdl"] = "models/freshdead/freshdead_05.mdl",
		["models/cellar/characters/oldcitizens/female_05.mdl"] = "models/freshdead/freshdead_06.mdl",
		["models/cellar/characters/oldcitizens/female_06.mdl"] = "models/freshdead/freshdead_05.mdl",
		["models/cellar/characters/oldcitizens/female_07.mdl"] = "models/freshdead/freshdead_06.mdl",
		["models/cellar/characters/oldcitizens/female_08.mdl"] = "models/freshdead/freshdead_05.mdl",
		["models/cellar/characters/oldcitizens/female_09.mdl"] = "models/freshdead/freshdead_05.mdl",
		["models/cellar/characters/oldcitizens/female_10.mdl"] = "models/freshdead/freshdead_06.mdl",
		["models/cellar/characters/oldcitizens/female_11.mdl"] = "models/freshdead/freshdead_05.mdl",
		["models/cellar/characters/oldcitizens/female_12.mdl"] = "models/freshdead/freshdead_07.mdl",
		["models/cellar/characters/oldcitizens/female_13.mdl"] = "models/freshdead/freshdead_07.mdl",
		["models/cellar/characters/oldcitizens/female_14.mdl"] = "models/freshdead/freshdead_07.mdl",
		["models/cellar/characters/oldcitizens/female_15.mdl"] = "models/freshdead/freshdead_05.mdl",
		["models/cellar/characters/oldcitizens/female_16.mdl"] = "models/freshdead/freshdead_06.mdl",
		["models/cellar/characters/oldcitizens/male_01.mdl"] = "models/freshdead/freshdead_01.mdll",
		["models/cellar/characters/oldcitizens/male_02.mdl"] = "models/freshdead/freshdead_02.mdl",
		["models/cellar/characters/oldcitizens/male_03.mdl"] = "models/freshdead/freshdead_03.mdl",
		["models/cellar/characters/oldcitizens/male_04.mdl"] = "models/freshdead/freshdead_04.mdl",
		["models/cellar/characters/oldcitizens/male_05.mdl"] = "models/zombie/grabber_06.mdl",
		["models/cellar/characters/oldcitizens/male_06.mdl"] = "models/zombie/seeker_02.mdl",
		["models/cellar/characters/oldcitizens/male_07.mdl"] = "models/zombie/grabber_08.mdl",
		["models/cellar/characters/oldcitizens/male_08.mdl"] = "models/zombie/junkie_03.mdl",
		["models/cellar/characters/oldcitizens/male_09.mdl"] = "models/zombie/grabber_10.mdl",
		["models/cellar/characters/oldcitizens/male_10.mdl"] = "models/zombie/grabber_07.mdl",
		["models/cellar/characters/oldcitizens/male_11.mdl"] = "models/zombie/infected_07.mdl",
		["models/cellar/characters/oldcitizens/male_12.mdl"] = "models/zombie/grabber_03.mdl",
		["models/cellar/characters/oldcitizens/male_13.mdl"] = "models/zombie/grabber_06.mdl",
		["models/cellar/characters/oldcitizens/male_14.mdl"] = "models/corrupt/zombie_02.mdl",
		["models/cellar/characters/oldcitizens/male_15.mdl"] = "models/zombie/infected_12.mdl",
		["models/cellar/characters/oldcitizens/male_16.mdl"] = "models/infected/new_infected_01.mdl",
		["models/cellar/characters/oldcitizens/male_17.mdl"] = "models/zombie/grabber_09.mdl",
		["models/cellar/characters/oldcitizens/male_18.mdl"] = "models/zombie/grabber_05.mdl"
	}

	function PLUGIN:StartApocalypse()
		local players = player.GetAll()

		for _, ply in ipairs(players) do
			self:InfectCharacter(ply:GetCharacter())
		end
	end

	function PLUGIN:InfectCharacter(character)
		if character:IsOTA() then return end
		if character:GetFaction() == FACTION_VORTIGAUNT then return end
		if character:GetData("zombie") then return end

		local hasVaccine = character:GetData("hasVaccine", false)

		if not hasVaccine then
			character:SetData("zombie", true)

			local timerID = "infection_" .. character:GetID()
			timer.Create(timerID, 600, 3, function()
				if not character then
					timer.Remove(timerID)
				end
				self:AdvanceDisease(character)
			end)
		end
	end

	function PLUGIN:AdvanceDisease(character)
		if character:IsOTA() then return end
		print("AdvanceDisease")

		local stage = character:GetData("zstage", 0)
		stage = math.Clamp(stage + 1, 0, 3)
		character:SetData("zstage", stage)

		if stage == 1 then
			timer.Simple(4, function()
				ix.chat.Send(character:GetPlayer(), "me", "начинает непроизвольно кашлять.")
				timer.Simple(4, function()
					ix.chat.Send(character:GetPlayer(), "me", "дрожит и нервно осматривается, постукивая зубами.")
				end)
			end)
		elseif stage == 2 then
			timer.Simple(4, function()
				ix.chat.Send(character:GetPlayer(), "me", "кашляет кровью и тяжело дышит.")
			end)

		elseif stage == 3 then
			ix.chat.Send(character:GetPlayer(), "me", "теряет свой рассудок и впадает в бешенство.")
			local items = character:GetInventory():GetItemsByBase("base_weaponstest", true)

			for _, item in pairs(items) do
				if isfunction(item.Unequip) then
					item:Unequip(character:GetPlayer(), true)
				end
			end

			if character:IsCombine() then
				character:SetModel("models/cpassic/cpassic.mdl")
			else
				character:SetModel(self.models[character:GetModel()] or table.Random(self.models))
			end
		end
	end
end
function PLUGIN:CanPlayerEquipItem(client, item, slot)
	if IsValid(client) and client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end

function PLUGIN:CanPlayerViewInventory()
	if LocalPlayer():GetCharacter():GetData("zstage") == 3 then
		return false
	end
end

function PLUGIN:CanPlayerInteractItem(client, action)
	if IsValid(client) and client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end

function PLUGIN:CanPlayerInteractEntity(client, entity)
	if IsValid(client) and client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end