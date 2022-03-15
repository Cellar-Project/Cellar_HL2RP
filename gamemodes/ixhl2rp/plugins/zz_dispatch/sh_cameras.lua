dispatch.SetCameraData("ix_rationdispenser", {
	CameraType = "РАЗДАТЧИК РАЦИОНОВ",
	Static = true,
	Offset = Vector(4, 0, 0),
	Name = function(self, entity)
		return "R:003:DISPR"
	end
})

dispatch.SetCameraData("ix_combinelock", {
	CameraType = "ЗАМОК",
	Static = true,
	Offset = Vector(4, 0, 0),
	DefaultName = function(self, entity)
		local name = string.gsub(entity.SaveCRC, "^(%d%d%d%d)(%d)", "LOCK:%1:%2")
		
		return name
	end
})

dispatch.SetCameraData("npc_combine_camera", {
	CameraType = "КАМЕРА",
	MaxPitch = {-25, 45},
	MaxYaw = {-60, 60},
	Offset = Vector(0, 0, -30),
})
