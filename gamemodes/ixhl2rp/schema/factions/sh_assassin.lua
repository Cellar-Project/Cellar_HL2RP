FACTION.name = "Ассассин Патруля"
FACTION.isDefault = false
FACTION.color = Color(151, 42, 97)
-- FACTION.scoreboardClass = "scOTA"
-- This file and plugins/zz_assassin/factions/sh_assassin.lua both resolve to the
-- faction uniqueID "assassin", so they share one table and the plugin copy (which
-- loads later) wins on every field it sets. The model and gender below are kept in
-- sync with it on purpose; only models/schwarzkruppzo/assassin.mdl has an animation
-- class registered (see plugins/zz_assassin/sh_plugin.lua). Do not delete this file:
-- faction indices are assigned in load order, so removing it renumbers other factions.
FACTION.models = {
	[1] = {"models/schwarzkruppzo/assassin.mdl"}
}

FACTION.runSounds = {[0] = "NPC_CombineS.RunFootstepLeft", [1] = "NPC_CombineS.RunFootstepRight"}
-- FACTION.typingBeeps = {"NPC_MetroPolice.Radio.On", "NPC_MetroPolice.Radio.Off"}
FACTION.genders = {2}

FACTION.isGloballyRecognized = true
FACTION.dontNeedFood = true
FACTION.defaultLevel = 6
FACTION.startSkills = {
	["athletics"] = 10,
	["acrobatics"] = 10,
	["guns"] = 10,
	["unarmed"] = 5,
	["medicine"] = 5,
	["meleeguns"] = 10,
	["impulse"] = 10,
}
FACTION.listenChannels = {
	["cp_main"] = 1,
	["overwatch"] = 1,
}

function FACTION:GetModels(client, gender)
	return self.models[1]
end

function FACTION:GetDefaultName(client)
	return "OW:c08.ASSASSIN-" .. math.random(1, 99), true
end

function FACTION:OnCharacterCreated(client, character)
	character:CreateIDCard("ota_access")
	character:SetSpecial("in", 10)
	character:SetSpecial("en", 10)
	character:SetSpecial("pe", 10)
end

function FACTION:CharacterLoaded(character)
end

function FACTION:OnTransfered(client)
	local character = client:GetCharacter()

	character:SetName(self:GetDefaultName())
	character:SetModel(self.models[1])
end

FACTION.npcRelations = {
	["npc_turret_floor"] = D_NU,
	["npc_combine_camera"] = D_NU,
	["npc_turret_ceiling"] = D_NU,
	["npc_rollermine"] = D_NU,
	["npc_helicopter"] = D_NU,
	["npc_combinegunship"] = D_NU,
	["npc_strider"] = D_NU,
	["npc_metropolice"] = D_LI,
	["npc_hunter"] = D_NU,
	["npc_combine_s"] = D_NU,
	["CombinePrison"] = D_NU,
	["CombineElite"] = D_NU,
	["npc_manhack"] = D_LI
}

FACTION_ASSASSIN = FACTION.index

Schema:SetFactionGroup(FACTION_ASSASSIN, FACTION_GROUP_OTA)