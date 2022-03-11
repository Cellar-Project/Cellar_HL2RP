util.AddNetworkString("dispatch.waypoint")

dispatch.waypoints = dispatch.waypoint or {}

function dispatch.GetWaypointReceivers()
	local recvs = {}

	for _, client in ipairs(player.GetAll()) do
		local char = client:GetCharacter()
		if !char then continue end
		
		if ix.faction.Get(char:GetFaction()).canSeeWaypoints then
			table.insert(recvs, client)
		end
	end

	return recvs
end

local function getFreeWaypoint()
	for i = 1, #dispatch.waypoints do
		if dispatch.waypoints[i] == nil then
			return i
		end
	end

	return #dispatch.waypoints + 1
end

function dispatch.AddWaypoint(pos, text, icon, time, addedBy)
	local index = getFreeWaypoint()

	local data = {}
	data.index = index
	data.pos = pos
	data.text = text
	data.type = icon
	data.addedBy = addedBy
	data.time = CurTime() + (time or 60)

	dispatch.waypoints[index] = data

	net.Start("dispatch.waypoint")
		net.WriteTable(data)
	net.Send(dispatch.GetWaypointReceivers())

	timer.Create("Waypoint"..index, (time or 60), 0, function()
		dispatch.waypoints[index] = nil
	end)
end

function dispatch.SyncWaypoints(receiver)
	for k, v in pairs(dispatch.waypoints) do
		net.Start("dispatch.waypoint")
			net.WriteTable(v)
		net.Send(receiver)
	end
end