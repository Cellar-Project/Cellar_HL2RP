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

dispatch.stability_codes = {
	[1] = {
		name = "ЗЕЛЁНЫЙ",
		text = "СОЦИО-СТАБИЛЬНОСТЬ В НОРМЕ",
		color = Color(128, 255, 128),
		isHidden = true
	},
	[2] = {
		name = "ЖЕЛТЫЙ",
		text = "СОЦИО-СТАБИЛЬНОСТЬ НИЖЕ НОРМЫ",
		color = Color(255, 200, 32)
	},
	[3] = {
		name = "КРАСНЫЙ",
		text = "СОЦИО-СТАБИЛЬНОСТЬ ПОД УГРОЗОЙ",
		color = Color(255, 32, 64)
	},
	[4] = {
		name = "ЧЁРНЫЙ",
		text = "СОЦИО-СТАБИЛЬНОСТЬ ПОТЕРЯНА, СУДЕБНОЕ РАЗБИРАТЕЛЬСТВО ОТМЕНЕНО",
		color = Color(225, 225, 225)
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

function dispatch.GetStability()
	return GetGlobalInt("stabilitycode", 1)
end

function dispatch.StabilityCode()
	return dispatch.stability_codes[dispatch.GetStability()] or dispatch.stability_codes[1]
end

function dispatch.GetFreeSquadTag()
	for tag = 1, #dispatch.available_tags do
		if dispatch.squads[tag] == nil then
			return tag
		end
	end

	return false
end

function dispatch.CreateSquad(leader, tagID, static, noLog)
	if !static and getmetatable(leader) != ix.meta.character then
		if !leader:GetCharacter() then
			return false
		end
		
		leader = leader:GetCharacter()
	end
	
	tagID = tagID or dispatch.GetFreeSquadTag()

	if !tagID then
		return false
	end
	
	local SQUAD = setmetatable({}, ix.meta.squad)
	SQUAD:Setup(tagID, leader, static)

	dispatch.squads[tagID] = SQUAD

	if !static and SERVER then
		SQUAD:Sync()
	end

	return SQUAD
end

dispatch.unassigned_squad = dispatch.unassigned_squad or dispatch.CreateSquad(nil, 1, true)

ix.util.Include("sh_interactions.lua")
ix.util.Include("cl_waypoints.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_spectate.lua")
ix.util.Include("sv_interactions.lua")
ix.util.Include("sv_waypoints.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_crc_saving.lua")

properties.Add("camera_setname", {
	MenuLabel = "Set Camera Name",
	Order = 400,
	MenuIcon = "icon16/lock_edit.png",

	Filter = function(self, entity, client)
		if !dispatch.GetCameraData(entity:GetClass()) then return false end
		if !gamemode.Call("CanProperty", client, "camera_setname", entity) then return false end

		return true
	end,

	Action = function(self, entity)
		Derma_StringRequest("Введите новое название камеры", "", "", function(text)
			self:MsgStart()
				net.WriteEntity(entity)
				net.WriteString(text)
			self:MsgEnd()
		end)
	end,

	Receive = function(self, length, client)
		local entity = net.ReadEntity()

		if !IsValid(entity) then return end
		if !self:Filter(entity, client) then return end

		local name = net.ReadString()

		entity:SetNetVar("cam", name)

		PLUGIN:SaveData()
	end
})

ix.lang.AddTable("russian", {
	stabilityChanged = "Вы успешно изменили статус-код!",
	waypointCooldown = "Вам нужно немного подождать прежде чем добавить новую метку!",
	addedWaypoint = "Вы успешно добавили метку!",
	combineNoAccess = "У Вас нет доступа к этим командам!",
	stabilityCmd = "Смена статус-кода (1 - 4: от зелёного до чёрного)",
	squadCreated = "Вы успешно сфомировали патрульную группу!"
})

ix.command.Add("StabilityCode", {
	description = "@stabilityCmd",
	arguments = {
		ix.type.number
	},
	OnRun = function(self, client, index)
		if !client:IsCombine() then
			return false
		end

		if client:GetCharacter():ReturnDatafilePermission() < 4 then
			return false
		end

		local id = math.Clamp(index, 1, #dispatch.stability_codes)

		SetGlobalInt("stabilitycode", id)

		return "@stabilityChanged"
	end
})

ix.command.Add("SquadCreate", {
	description = "@cmdPTCreate",
	OnRun = function(self, client, index)
		if !client:IsCombine() then
			return "@combineNoAccess"
		end

		local result, err = dispatch.CreateSquad(client)

		if result then
			ix.log.Add(client:GetCharacter(), "squadCreate", result:GetTagName())

			return "@squadCreated"
		end
	end
})

ix.command.Add("SquadJoin", {
	description = "@cmdPTCreate",
	arguments = {
		ix.type.number
	},
	OnRun = function(self, client, index)
		if !client:IsCombine() then
			return "@combineNoAccess"
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
			return "@combineNoAccess"
		end

		if (client.lastWaypointCooldown or 0) > CurTime() then
			return "@waypointCooldown"
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