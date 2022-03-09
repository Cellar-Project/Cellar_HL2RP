local PLUGIN = PLUGIN
PLUGIN.name = "Dispatch System"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

dispatch = dispatch or {
	name_format = "CCA:%s%s-%i",
	--unassigned_tag = "UNIT",
	available_tags = {
		"UNIT",
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

if SERVER then
	ix.log.AddType("squadCreate", function(char, tagname)
		return string.format("%s создал подразделение '%s'", char:GetOriginalName(), tagname)
	end)

	ix.log.AddType("squadDestroy", function(char, tagname)
		return string.format("%s расформировал подразделение '%s'", char:GetOriginalName(), tagname)
	end)
end

ix.util.Include("sh_ranks.lua")
ix.util.Include("meta/sh_squads.lua")

function dispatch.GetMemberLimit()
	return 5
end

function dispatch.GetSquads()
	return dispatch.squads
end

function dispatch.GetReceivers()
	local recvs = {}

	for _, client in ipairs(player.GetAll()) do
		if client:IsCombine() then
			table.insert(recvs, client)
		end
	end

	return recvs
end

/*
function dispatch.GetReceiversAI()
	local recvs = {}

	for _, client in ipairs(player.GetAll()) do
		if client:Team() == FACTION_DISPATCH then
			table.insert(recvs, client)
		end
	end

	return recvs
end
*/

function dispatch.GetFreeSquadTag()
	for tag = 1, #dispatch.available_tags do
		if dispatch.squads[tag] == nil then
			return tag
		end
	end

	return false
end

function dispatch.CreateSquad(leader, tagID, static)
	if !static and getmetatable(leader) != ix.meta.character then
		if !leader:GetCharacter() then
			return
		end
		
		leader = leader:GetCharacter()
	end
	
	tagID = tagID or dispatch.GetFreeSquadTag()

	if !tagID then
		return "No free tvs" --TODO: localize this
	end
	
	local SQUAD = setmetatable({}, ix.meta.squad)
	SQUAD:Setup(tagID, leader, static)

	dispatch.squads[tagID] = SQUAD

	if !static then
		if SERVER then
			SQUAD:Sync()

			ix.log.Add(leader, "squadCreate", SQUAD:GetTagName())
		end
	end

	return SQUAD
end

dispatch.unassigned_squad = dispatch.unassigned_squad or dispatch.CreateSquad(nil, 1, true)

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sh_spectate.lua")

ix.command.Add("SquadCreate", {
	description = "@cmdPTCreate",
	OnRun = function(self, client, index)
		if !client:IsCombine() then
			return "@CannotUseTeamCommands"
		end

		return dispatch.CreateSquad(client)
	end
})