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
					local yawDiff = math.AngleDifference(cam_ang.y, angles.y)

					if yawDiff >= max_yaw[2] then
						cam_ang.y = normalize(angles.y + max_yaw[2])
					elseif yawDiff <= max_yaw[1] then
						cam_ang.y = normalize(angles.y + max_yaw[1])
					end
		  		end

				cmd:SetViewAngles(cam_ang)
				return true
			end
		end
	end
end

do
	function dispatch.GetViewTrace()
		local eyepos, eyevec = EyePos(), gui.ScreenToVector(gui.MousePos())
		local ply = LocalPlayer()
		local filter = ply:GetViewEntity()

		if filter == ply then
			local veh = ply:GetVehicle()

			if veh:IsValid() and (!veh:IsVehicle() or !veh:GetThirdPersonMode()) then
				filter = {filter, veh, unpack(ents.FindByClass( "phys_bone_follower"))}
			end
		end

		local trace = util.TraceLine({
			start = eyepos,
			endpos = eyepos + eyevec * 4096,
			filter = filter
		})

		if !trace.Hit or !IsValid(trace.Entity) then
			trace = util.TraceLine({
				start = eyepos,
				endpos = eyepos + eyevec * 4096,
				filter = filter,
				mask = MASK_ALL
			})
		end

		return trace
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
		hook.Add("PostDrawTranslucentRenderables", "dispatch.spectate", dispatch.Draw3DCursor)

		vgui.Create "dispatch.main"
	else
		if IsValid(ix.gui.dispatch) then
			ix.gui.dispatch:Remove()
		end

		hook.Remove("ShouldRunSchemaScreenspaceEffects", "dispatch.spectate")
		hook.Remove("CalcView", "dispatch.spectate")
		hook.Remove("StartCommand", "dispatch.spectate")
		hook.Remove("InputMouseApply", "dispatch.spectate")
		hook.Remove("PostDrawTranslucentRenderables", "dispatch.spectate")
	end

	hook.Run("DispatchModeChanged", state)
end

function dispatch.Spectate(entity)
	ix.gui.dispatch:OnSpectate(entity)
end

function dispatch.StopSpectate()
	ix.gui.dispatch:OnStopSpectate()
end

net.Receive("dispatch.mode", function()
	dispatch.OnDispatchMode(net.ReadBool())
end)

net.Receive("dispatch.spectate", function()
	dispatch.Spectate(net.ReadEntity())
end)

net.Receive("dispatch.spectate.stop", dispatch.StopSpectate)