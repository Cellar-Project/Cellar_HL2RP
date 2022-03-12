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

dispatch.mpf_ranks = {
	[1] = {
		name = "Regular",
		class = function() 
			return CLASS_MPF 
		end
	},
	[2] = {
		name = "Rank Leader",
		class = function() 
			return CLASS_RL 
		end
	},
}

function dispatch.Rank(id)
	return dispatch.mpf_ranks[id] or dispatch.mpf_ranks[1]
end

function dispatch.GetRank(character)
	return ix.class.list[character:GetClass()].rank or 0
end

if SERVER then
	ix.log.AddType("squadCreate", function(char, tagname)
		return string.format("%s создал подразделение '%s'", char:GetOriginalName(), tagname)
	end)

	ix.log.AddType("squadDestroy", function(char, tagname)
		return string.format("%s расформировал подразделение '%s'", char:GetOriginalName(), tagname)
	end)
end

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

ix.util.Include("cl_interactions.lua")
ix.util.Include("cl_waypoints.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_spectate.lua")
ix.util.Include("sv_interactions.lua")
ix.util.Include("sv_waypoints.lua")
ix.util.Include("sv_hooks.lua")

ix.command.Add("SquadCreate", {
	description = "@cmdPTCreate",
	OnRun = function(self, client, index)
		if !client:IsCombine() then
			return "@CannotUseTeamCommands"
		end

		return dispatch.CreateSquad(client)
	end
})


ix.command.Add("SquadJoin", {
	description = "@cmdPTCreate",
	arguments = {
		ix.type.number
	},
	OnRun = function(self, client, index)
		if !client:IsCombine() then
			return "@CannotUseTeamCommands"
		end

		local squad = dispatch.GetSquads()[index]

		if squad then
			squad:AddMember(client:GetCharacter())
		end
	end
})

ix.command.Add("Waypoint", {
	description = "@cmdWaypointAdd",
	arguments = {ix.type.string, bit.bor(ix.type.string, ix.type.optional)},
	OnRun = function(self, client, type, text)
		if !client:IsCombine() then
			return "@cannotAddWaypoints"
		end

		if (client.lastWaypointCooldown or 0) > CurTime() then
			return "Wait a bit before adding new one!" -- TO DO: change to localized version
		end

		text = text or ""

		local trace = client:GetEyeTraceNoCursor()
		local position = trace.HitPos

		if math.abs(trace.HitNormal.z) > .98 then
			position:Add(Vector(0, 0, 30))
		end

		dispatch.AddWaypoint(position, text, type)

		client.lastWaypointCooldown = CurTime() + 5

		return "@addedWaypoint"
	end
})