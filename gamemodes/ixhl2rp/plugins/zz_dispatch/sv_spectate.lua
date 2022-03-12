util.AddNetworkString("dispatch.spectate")
util.AddNetworkString("dispatch.spectate.stop")
util.AddNetworkString("dispatch.spectate.request")
util.AddNetworkString("dispatch.mode")
util.AddNetworkString("dispatch.scanner")

function dispatch.SetDispatchMode(client, bool)
	client:SetNetVar("d", bool == true and bool or nil)

	net.Start("dispatch.mode")
		net.WriteBool(bool)
	net.Send(client)

	if bool then
		client:StripWeapons()
		client:StripAmmo()

		client:SetNoDraw(true)
		client:SetNotSolid(true)
		client:SetMoveType(MOVETYPE_NONE)
	else
		client:SetNoDraw(false)
		client:SetNotSolid(false)
		client:SetMoveType(MOVETYPE_WALK)

		dispatch.StopSpectate(client)
	end
end

function dispatch.Spectate(client, entity)
	if !IsValid(entity) or !IsValid(client) then return end
	if !dispatch.InDispatchMode(client) then return end
	
	client:SetNetworkOrigin(dispatch.GetCameraOrigin(entity))
	client:SetViewEntity(entity)
	client:SetEyeAngles(dispatch.GetCameraViewAngle(entity))

	net.Start("dispatch.spectate")
		net.WriteEntity(entity)
	net.Send(client)
end

function dispatch.StopSpectate(client)
	if !IsValid(client) then return end
	
	client:SetViewEntity(nil)

	net.Start("dispatch.spectate.stop")
	net.Send(client)
end

net.Receive("dispatch.spectate.request", function(len, client)
	dispatch.Spectate(client, net.ReadEntity())
end)

do
	local SCANNERS, SPAWNS = ix.plugin.list["combinescanners"],  ix.plugin.list["spawns"]

	function dispatch.DeployScanner(client)
		if !dispatch.InDispatchMode(client) then 
			return 
		end

		if client:IsPilotScanner() or IsValid(SCANNERS:GetActiveScanners()[client]) then
			return
		end

		local spawnPoints = SPAWNS.spawns["metropolice"]["scanner"]

		if !spawnPoints or #spawnPoints <= 0 then 
			return 
		end

		local randomSpawn = math.random(1, #spawnPoints)
		local pos = spawnPoints[randomSpawn]
		
		SCANNERS.activeID = SCANNERS.activeID + 1

		local scanner = ents.Create("ix_scanner")
		scanner:SetPos(pos)
		scanner:Spawn()
		scanner:SetID(SCANNERS.activeID)

		SCANNERS:GetActiveScanners()[client] = scanner

		scanner:Transmit(client)
		client:SetNWEntity("Scanner", scanner)
	end

	net.Receive("dispatch.scanner", function(len, client)
		dispatch.DeployScanner(client)
	end)
end