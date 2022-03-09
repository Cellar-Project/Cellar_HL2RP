ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:Initialize()  
	if IsValid(dispatch.cam_manager) then
		dispatch.cam_manager:Remove()
	end
	
	dispatch.cam_manager = self

	self:SetName("cam_manager")
end

function ENT:AcceptInput(name, act, caller, data)
	if name == "Scan" then
		if IsValid(act) then
			self:OnFoundPlayer(caller, act)
		end
	end
end

function ENT:OnFoundPlayer(camera, client)
	print(camera, client)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end

if SERVER then
	hook.Add("OnEntityCreated", "dispatch.cam_manager", function(entity)
		if !IsValid(entity) then return end
		
		if entity:IsNPC() and entity:GetClass() == "npc_combine_camera" then
			entity:SetKeyValue("innerradius", 800)
			entity:SetKeyValue("outerradius", 800)
			entity:SetKeyValue("OnFoundPlayer", "cam_manager,Scan")
		end
	end)

	hook.Add("InitPostEntity", "dispatch.cam_manager", function()
		local manager = ents.Create("ix_cam_manager") 
		manager:Spawn()
	end)
end