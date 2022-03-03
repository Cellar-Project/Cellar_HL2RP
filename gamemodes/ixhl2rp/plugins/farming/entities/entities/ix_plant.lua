ENT.Type = "anim"
ENT.Author = "Vintage Thief"
ENT.PrintName = "Растение"
ENT.Description = "Посаженное растение"
ENT.Spawnable = false
ENT.PopulateEntityInfo = true

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
		self.growth_n = 0
		self.phase = 0

		timer.Create(self.timerName, confPhaseTime, 0, function()

			local confPhaseAmount = ix.config.Get("phaseamount")
			local confPhaseRate = ix.config.Get("phaserate")
			local confPhases = ix.config.Get("phases")
			self.growth_n = self.growth_n + confPhaseRate

			if self.growth_n >= confPhaseAmount then
				self.phase = self.phase + 1
			end

			if self.phase >= confPhases then
				self:EndGrowth()
			end
		end)

		self:SetModel(PLUGIN.growmodels[math.random(1, #PLUGIN.growmodels)])
	end

	function ENT:SetClass(class)
		self.class = class
	end

	function ENT:EndGrowth()
		self:SetNetVar("grown", 1)
		timer.Remove(self.timerName)
	end

	function ENT:OnRemove()
		if self.timerName then
			timer.Remove(self.timerName)
		end
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

	function ENT:OnPopulateEntityInfo(tooltip)

		local title = tooltip:AddRow("")
		title:SetText("")
		title:SetImportant()
		title:SizeToContents()
	end

end