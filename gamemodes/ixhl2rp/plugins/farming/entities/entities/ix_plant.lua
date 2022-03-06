ENT.Type = "anim"
ENT.Author = "Vintage Thief, maxxoft"
ENT.PrintName = "Растение"
ENT.Description = "Посаженное растение"
ENT.Spawnable = false
ENT.PopulateEntityInfo = true

if (SERVER) then

	local PLUGIN = PLUGIN

	function ENT:Initialize()
		local pos = self:GetPos()

		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetCollisionBounds(pos - Vector(3, 4, 4), pos + Vector(3, 3, 3))
		self:PhysicsInit(SOLID_BBOX)

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
			physicsObject:EnableMotion(false)
		end

		self.timerName = "phasetimer" .. self:EntIndex()

		local phaseTime = ix.config.Get("phasetime")
		self.growth_n = 0
		self.phase = 0

		timer.Create(self.timerName, phaseTime, 0, function()

			local phaseAmount = ix.config.Get("phaseamount")
			local phaseRate = ix.config.Get("phaserate")
			local phases = ix.config.Get("phases")
			self.growth_n = self.growth_n + phaseRate

			if (self.growth_n >= phaseAmount) then
				self.phase = self.phase + 1
			end

			if (self.phase >= phases) then
				self:EndGrowth()
			end
		end)

		self:SetModel(PLUGIN.growmodels[math.random(1, #PLUGIN.growmodels)])
	end

	function ENT:SetClass(class)
		self.class = class
	end

	function ENT:Use(activator) end

	function ENT:GetClass()
		return self.class
	end

	function ENT:SetPhase(phase)
		self.phase = math.Clamp(phase, 0, ix.config.Get("phases"))
	end

	function ENT:GetPhase()
		return self.phase
	end

	function ENT:EndGrowth()
		self:SetNetVar("grown", 1)
		timer.Remove(self.timerName)
		print("[" .. tostring(self) .. "]" .. " я вырос!!")
	end

	function ENT:OnRemove()
		if (self.timerName) then
			timer.Remove(self.timerName)
		end
	end

else

	function ENT:OnPopulateEntityInfo(tooltip)
		local name = self:GetName()

		local title = tooltip:AddRow("name")
		title:SetText(name)
		title:SetImportant()
		title:SizeToContents()
	end

end

do

	function ENT:SetName(name)
		self.name = name
		self:SetNetVar("name", name)
	end

	function ENT:GetName()
		return self.name or self:GetNetVar("name")
	end

end