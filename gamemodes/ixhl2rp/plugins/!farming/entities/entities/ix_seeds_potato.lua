ENT.Type = "anim"
ENT.Author = "Vintage Thief"
ENT.PrintName = "Семена картошки"
ENT.Description = "Небольшая упаковка с семенами."
ENT.Spawnable = false

if (SERVER) then

	local PLUGIN = PLUGIN

	function ENT:Initialize()
		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetSolid(SOLID_VPHYSICS)

		local physicsObject = self:GetPhysicsObject()

		if IsValid(physicsObject) then
			physicsObject:Wake()
			physicsObject:EnableMotion(false)
		end

		self.timerName = "phasetimer" .. self:EntIndex()

		local confPhaseTime = ix.config.Get("phasetime")
		local growth_n = 0
		local phase = 0
		self:SetNetVar("grown", 0) -- изменить на получение из БД

		timer.Create(self.timerName, confPhaseTime, 0, function()

			local confPhaseAmount = ix.config.Get("phaseamount")
			local confPhaseRate = ix.config.Get("phaserate")
			local confPhases = ix.config.Get("phases")
			growth_n = math.Clamp(growth_n + confPhaseRate, 0, confPhaseAmount)
			phase = 1
			if growth_n == confPhaseAmount then
				phase = math.Clamp(phase + 1, 0, confPhases)
				if phase == confPhases then
					self:SetNetVar("grown", 1)
				end
			end

			self:SetModel(PLUGIN.growmodels[math.random(1, #PLUGIN.growmodels)])
		end)
	end

	function ENT:OnRemove()
		timer.Remove(self.timerName)
	end

else

	function ENT:Draw()
		self:DrawModel()

		cam.Start2D()
			local pos = self:GetPos():ToScreen()
			local growth = self:GetNetVar("grown")
			draw.DrawText(growth, "Default", pos.x, pos.y, color_white, TEXT_ALIGN_CENTER)
		cam.End2D()
	end

end