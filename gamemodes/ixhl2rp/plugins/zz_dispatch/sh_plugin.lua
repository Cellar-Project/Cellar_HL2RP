local PLUGIN = PLUGIN
PLUGIN.name = "Dispatch System"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

dispatch = dispatch or {
	name_format = "CCA:c08.%s",
	unassigned_tag = "UNIT",
	available_tags = {
		"DEFENDER",
		"HERO",
		"JURY",
		"KING",
		"LINE",
		"PATROL",
		"QUICK",
		"ROLLER",
		"STICK",
		"TAP",
		"UNION",
		"VICTOR",
		"XRAY",
		"YELLOW",
		"VICE"
	},
	squads = {}
}

ix.util.Include("meta/sh_squads.lua")

function dispatch.GetReceivers()
	local recvs = {}

	for _, client in ipairs(player.GetAll()) do
		if client:IsCombine() then
			table.insert(recvs, client)
		end
	end

	return recvs
end

function dispatch.GetFreeSquadTag()
	for tag = 1, #dispatch.available_tags do
		if dispatch.squads[tag] == nil then
			return tag
		end
	end

	return false
end

function dispatch.CreateSquad(leader, tagID)
	tagID = tagID or dispatch.GetFreeSquadTag()

	if !tagID then
		return "No free tvs" --TODO: localize this
	end
	
	local SQUAD = setmetatable({}, ix.meta.squad)
	SQUAD:Setup(tagID, leader)

	if SERVER then
		SQUAD:Sync()

		ix.log.AddRaw(string.format("%s has created squad %s", leader:GetName(), SQUAD:GetTagName()))  --TODO: switch raw to localized
	end

	dispatch.squads[tagID] = SQUAD

	return SQUAD
end

ix.command.Add("SquadCreate", {
	description = "@cmdPTCreate",
	OnRun = function(self, client, index)
		if !client:IsCombine() then
			return "@CannotUseTeamCommands"
		end

		return dispatch.CreateSquad(client:GetCharacter())
	end
})