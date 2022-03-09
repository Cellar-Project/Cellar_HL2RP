local empty = Vector()
local CAM = ix.meta.cameratype or {}
CAM.__index = CAM

function CAM:Name(entity) 
	return "UNKNOWN"
end

function CAM:Type() return self.cam_type end
function CAM:IsStatic() return self.locked_view end
function CAM:ViewAngle(entity) return entity:GetAngles() end
function CAM:ViewOffset(entity) return self.view_offset end
function CAM:MaxYaw() return self.max_yaw end
function CAM:MaxPitch() return self.max_pitch end

function CAM:Setup(data)
	self.cam_type = data.CameraType
	self.locked_view = data.Static or false
	self.max_yaw = data.MaxYaw
	self.max_pitch = data.MaxPitch
	self.view_offset = data.Offset
end

ix.meta.cameratype = CAM

do
	local ent_cache = CLIENT and {} or (dispatch.cameras_cache or {})
	dispatch.cameras_cache = ent_cache or {}
	dispatch.camdata = dispatch.camdata or {}

	function dispatch.FindCameras()
		return ent_cache
	end

	local function RevalidateCache()
		for k, v in ipairs(ent_cache) do
			if IsValid(v) then continue end

			ent_cache[k] = nil
		end
	end

	hook.Add("OnEntityCreated", "dispatch.camera", function(entity)
		if !IsValid(entity) then return end

		local camdata = dispatch.GetCameraData(entity:GetClass())

		if camdata then
			ent_cache[entity:EntIndex()] = entity

			entity.GetCameraData = function() return camdata end
			entity:CallOnRemove("dispatch.camera", function(ent)
				timer.Simple(0, function()
					if IsValid(ent) then return end

					RevalidateCache()
				end)
			end)
		end
	end)

	function dispatch.GetCameraData(classname)
		return dispatch.camdata[classname]
	end

	function dispatch.SetCameraData(classname, data)		
		local CAM = setmetatable({}, ix.meta.cameratype)
		CAM:Setup(data)

		dispatch.camdata[classname] = CAM
	end
end