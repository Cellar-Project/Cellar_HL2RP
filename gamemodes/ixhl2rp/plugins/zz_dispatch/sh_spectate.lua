if SERVER then
	util.AddNetworkString("dispatch.spectate")
	util.AddNetworkString("dispatch.spectate.stop")
	util.AddNetworkString("dispatch.mode")
else
	function dispatch.OnDispatchMode(state)
		if state then
			ix.gui.combine:Remove()

			timer.Remove("ixRandomDisplayLines")
		end
	end
	hook.Add("ShouldRunSchemaScreenspaceEffects", "dispatch.spectate", function()
		return IsValid(LocalPlayer():GetViewEntity()) == true or nil
	end)

	hook.Add("CalcView", "dispatch.spectate", function(client, origin, angles, fov, znear, zfar)
		local camera = client:GetViewEntity()

		if IsValid(camera) then
			local data = {
				origin = client:GetViewEntity():GetPos(),
				angles = client:EyeAngles(),
				drawviewer = true
			}

			return data
		end
	end)

	gui.EnableScreenClicker(true)
	local show_cursor = true

	hook.Add("StartCommand", "dispatch.spectate", function(client, cmd)
		local camera = LocalPlayer():GetViewEntity()

		if IsValid(camera) then
			if input.IsMouseDown(MOUSE_LEFT) then
				if show_cursor then
					gui.EnableScreenClicker(false)
				end
				
				show_cursor = false
			elseif !cmd:KeyDown(IN_ATTACK) and !show_cursor then
				if !show_cursor then
					gui.EnableScreenClicker(true)
				end
				
				show_cursor = true
			end
		end
	end)

	hook.Add("InputMouseApply", "dispatch.spectate", function(cmd)
		local camera = LocalPlayer():GetViewEntity()

		if IsValid(camera) and show_cursor then
			cmd:SetMouseX(0)
			cmd:SetMouseY(0)

			return true
		end
	end)
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
			end
		end
	end
end

local CameraTypes = {
	["item_suitcharger"] = true
}

do
	if CLIENT then
		function dispatch.Spectate(entity)
		end

		function dispatch.StopSpectate()
		end

		net.Receive("dispatch.spectate", function()
			dispatch.Spectate(net.ReadEntity())
		end)

		net.Receive("dispatch.spectate.stop", dispatch.StopSpectate)
	else
		function dispatch.Spectate(client, entity)
			if !IsValid(entity) or !IsValid(client) then return end
			if !dispatch.InDispatchMode(client) then return end
			
			client:SetNetworkOrigin(entity:GetPos())
			client:SetViewEntity(entity)

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
	end
end