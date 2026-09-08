local PLUGIN = PLUGIN

local function InstallNextbotTargeting(warn)
	local stored = scripted_ents.GetStored("nz_base")
	local nb_npc = GetConVar("nb_npc")
	local ai_ignoreplayers = GetConVar("ai_ignoreplayers")
	local nb_targetmethod = GetConVar("nb_targetmethod")

	if not (stored and istable(stored.t) and nb_npc and ai_ignoreplayers and nb_targetmethod) then
		if warn and not PLUGIN.warnedNextbotDependency then
			PLUGIN.warnedNextbotDependency = true
			ErrorNoHalt("[ix apocalypse] Optional nz_base entity or nb_npc/ai_ignoreplayers/nb_targetmethod convars unavailable; " ..
				"nextbot targeting integration skipped. Character infection remains enabled.\n")
		end

		return
	end

	local oldSearch = stored.t.SearchForEnemy

	function stored.t:SearchForEnemy(ents)
		for _, v in pairs(ents) do
			if nb_targetmethod:GetInt() == 1 then
				if not self:IsLineOfSightClear(v) then
					return
				end
			end

			if nb_npc:GetInt() == 1 then
				local enemy = math.random(1, 2)

				if enemy == 1 then
					if v:IsPlayer() and v:Alive() then
						local character = v:GetCharacter()

						if ai_ignoreplayers:GetInt() == 0 and character and character:GetData("zstage") != 3 then
							self:SetEnemy(v)
							return true
						end
					else
						if v:IsNPC() and v != self and not string.find(v:GetClass(), "npc_nextbot_*") and not string.find(v:GetClass(), "npc_bullseye") and not string.find(v:GetClass(), "npc_grenade_frag") and not string.find(v:GetClass(), "animprop_generic") then
							self:SetEnemy(v)
							return true
						end
					end
				else
					if v:IsNPC() and v != self and not string.find(v:GetClass(), "npc_nextbot_*") and not string.find(v:GetClass(), "npc_bullseye") and not string.find(v:GetClass(), "npc_grenade_frag") and not string.find(v:GetClass(), "animprop_generic") then
						self:SetEnemy(v)
						return true
					end
				end
			elseif v:IsPlayer() and v:Alive() then
				local character = v:GetCharacter()

				if ai_ignoreplayers:GetInt() == 0 and character and character:GetData("zstage") != 3 then
					self:SetEnemy(v)
					return true
				end
			end
		end

		self:SetEnemy(nil)
		return false
	end

	-- Existing instances copy inherited methods; leave subclass overrides intact.
	for _, entity in ipairs(ents.GetAll()) do
		if (entity:GetClass() == "nz_base" or scripted_ents.IsBasedOn(entity:GetClass(), "nz_base")) and entity.SearchForEnemy == oldSearch then
			entity.SearchForEnemy = stored.t.SearchForEnemy
		end
	end

	local base = baseclass.Get("nz_base")

	if base and base.SearchForEnemy == oldSearch then
		base.SearchForEnemy = stored.t.SearchForEnemy
	end
end

-- Install early when possible, then retry after ordinary addon startup hooks.
InstallNextbotTargeting(false)

function PLUGIN:InitPostEntity()
	timer.Simple(0, function()
		InstallNextbotTargeting(true)
	end)
end

PLUGIN.OnReloaded = PLUGIN.InitPostEntity

function PLUGIN:CharacterLoaded(character)
	if character:GetData("zombie", false) and character:GetData("zstage", 1) != 3 then
		local timerID = "ixInfection_" .. character:GetID()
		timer.Create(timerID, 600, 3 - character:GetData("zstage"), function()
			if not character then
				timer.Remove(timerID)
			end
			self:AdvanceDisease(character)
		end)
	end
end

function PLUGIN:CanPlayerEquipItem(client, item, slot)
	if not IsValid(client) then return end
	local char = client:GetCharacter()
	return not (char:GetData("zombie", false) and (char:GetData("zstage") == 3))
end

function PLUGIN:CanPlayerInteractItem(client, action)
	if not IsValid(client) then return end
	local char = client:GetCharacter()
	return not (char:GetData("zombie", false) and (char:GetData("zstage") == 3))
end

hook.Add("prone.CanEnter", "Infection", function(client)
	if not IsValid(client) then return end
	local char = client:GetCharacter()
	return not (char:GetData("zombie", false) and (char:GetData("zstage") == 3))
end)
