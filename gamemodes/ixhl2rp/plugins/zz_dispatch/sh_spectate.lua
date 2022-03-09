ix.util.Include("meta/sh_cams.lua")
ix.util.Include("sh_cameras.lua")

function dispatch.GetCameraOrigin(camera)
	if !camera.GetCameraData then 
		return camera:GetPos() 
	end
	
	local data = camera:GetCameraData()
	local pos = camera:GetPos()

	if data then
		local offset = data:ViewOffset(camera)

		if offset then
			pos = pos + (camera:GetForward() * offset.x) + (camera:GetRight() * offset.y) + (camera:GetUp() * offset.z)
		end
	end
	
	return pos
end

function dispatch.GetCameraViewAngle(camera)
	local data = camera:GetCameraData()
	local ang = camera:GetAngles()

	if data then
		local new_ang = data:ViewAngle(camera)

		if new_ang then
			ang = new_ang
		end
	end
	
	ang.z = 0

	return ang
end

if SERVER then
	util.AddNetworkString("dispatch.spectate")
	util.AddNetworkString("dispatch.spectate.stop")
	util.AddNetworkString("dispatch.spectate.request")
	util.AddNetworkString("dispatch.mode")
	util.AddNetworkString("dispatch.scanner")
else
	hook.Remove("PlayerButtonDown", "Liquids")
	hook.Remove("PlayerButtonUp", "Liquids")

	function dispatch.CalcView(client, origin, angles, fov, znear, zfar)
		local camera = dispatch.IsSpectating(client)

		if IsValid(camera) then
			local pos = dispatch.GetCameraOrigin(client:GetViewEntity())

			local data = {
				origin = pos,
				angles = client:EyeAngles(),
				drawviewer = true
			}

			return data
		end
	end

	local cam_ang = Angle()
	local show_cursor = true
	local save_x, save_y = 0, 0
	local clamp, normalize = math.Clamp, math.NormalizeAngle

	function dispatch.StartCommand(client, cmd)
		local camera = dispatch.IsSpectating(LocalPlayer())

		if IsValid(camera) and !input.IsKeyDown(KEY_LSHIFT) then
			if input.IsMouseDown(MOUSE_LEFT) and !ix.gui.dispatch:IsChildHovered() then
				if show_cursor then
					gui.EnableScreenClicker(false)
					save_x, save_y = input.GetCursorPos()
					cam_ang = LocalPlayer():EyeAngles()
				end
				
				show_cursor = false
			elseif !cmd:KeyDown(IN_ATTACK) and !show_cursor then
				if !show_cursor then
					gui.EnableScreenClicker(true)
					input.SetCursorPos(save_x, save_y)
				end
				
				show_cursor = true
			end
		end

		if show_cursor and !vgui.CursorVisible() then
			gui.EnableScreenClicker(true)
		end
	end

	function dispatch.InputMouseApply(cmd, x, y)
		local camera = dispatch.IsSpectating(LocalPlayer())

		if IsValid(camera) then
			local camdata = camera.GetCameraData and camera:GetCameraData()

			if show_cursor then
				cmd:SetMouseX(0)
				cmd:SetMouseY(0)

				return true
			else
				if camdata then
					local max_yaw, max_pitch, angles = camdata:MaxYaw(), camdata:MaxPitch(), camdata:ViewAngle(camera)

					cam_ang.p = clamp(normalize(cam_ang.p + y * GetConVar("m_pitch"):GetFloat()), max_pitch and max_pitch[1] or -89, max_pitch and max_pitch[2] or 89)
			  		cam_ang.y = normalize(cam_ang.y - x * GetConVar("m_yaw"):GetFloat())

					if max_yaw then
						cam_ang.y = clamp(cam_ang.y, angles.y + max_yaw[1], angles.y + max_yaw[2])
			  		end

					cmd:SetViewAngles(cam_ang)
					return true
				end
			end
		end
	end

	function dispatch.OnDispatchMode(state)
		if state then
			ix.gui.combine:Remove()

			timer.Remove("ixRandomDisplayLines")

			gui.EnableScreenClicker(true)
			show_cursor = true

			hook.Add("ShouldRunSchemaScreenspaceEffects", "dispatch.spectate", function()
				return dispatch.IsSpectating(LocalPlayer())
			end)

			hook.Add("CalcView", "dispatch.spectate", dispatch.CalcView)
			hook.Add("StartCommand", "dispatch.spectate", dispatch.StartCommand)
			hook.Add("InputMouseApply", "dispatch.spectate", dispatch.InputMouseApply)

			vgui.Create "dispatch.main"
		else
			if IsValid(ix.gui.dispatch) then
				ix.gui.dispatch:Remove()
			end

			hook.Remove("ShouldRunSchemaScreenspaceEffects", "dispatch.spectate")
			hook.Remove("CalcView", "dispatch.spectate")
			hook.Remove("StartCommand", "dispatch.spectate")
			hook.Remove("InputMouseApply", "dispatch.spectate")
		end

		hook.Run("DispatchModeChanged", state)
	end
end

do
	function dispatch.InDispatchMode(client)
		return client:GetNetVar("d")
	end
		
	if CLIENT then
		net.Receive("dispatch.mode", function()
			dispatch.OnDispatchMode(net.ReadBool())
		end)
	else
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

		hook.Add("CharacterLoaded", "dispatch.spectate", function(character)
			local client = character:GetPlayer()

			if dispatch.InDispatchMode(client) and character:GetFaction() != FACTION_DISPATCH then
				dispatch.SetDispatchMode(client, false)
			end
		end)
	end
end

do
	if CLIENT then
		function dispatch.Spectate(entity)
			ix.gui.dispatch:OnSpectate(entity)
		end

		function dispatch.StopSpectate()
			ix.gui.dispatch:OnStopSpectate()
		end

		net.Receive("dispatch.spectate", function()
			dispatch.Spectate(net.ReadEntity())
		end)

		net.Receive("dispatch.spectate.stop", dispatch.StopSpectate)
	else
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
	end

	function dispatch.IsSpectating(client)
		local entity = client:GetViewEntity()

		if entity == client then
			return
		end
		
		return dispatch.InDispatchMode(client) and (IsValid(entity) and entity or false) or false
	end
end

do
	if SERVER then
		local SCANNER = ix.plugin.list["combinescanners"]
		function dispatch.DeployScanner(client)
			if client:IsPilotScanner() then return end
			
			if IsValid(SCANNER:GetActiveScanners()[client]) then
				return
			end

			local spawnPoints = ix.plugin.list["spawns"].spawns["metropolice"]["scanner"]

			if (!spawnPoints or #spawnPoints <= 0) then return end

			local randomSpawn = math.random(1, #spawnPoints)
			local pos = spawnPoints[randomSpawn]
			
			SCANNER.activeID = SCANNER.activeID + 1

			local scanner = ents.Create("ix_scanner")
			scanner:SetPos(pos)
			scanner:Spawn()
			scanner:SetID(SCANNER.activeID)

			SCANNER:GetActiveScanners()[client] = scanner

			scanner:Transmit(client)
			client:SetNWEntity("Scanner", scanner)
		end

		net.Receive("dispatch.scanner", function(len, client)
			dispatch.DeployScanner(client)
		end)
	end
end