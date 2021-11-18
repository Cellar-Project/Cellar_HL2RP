local PLUGIN = PLUGIN


ENT.Type = "anim"
ENT.PrintName = "Water Collector"
ENT.Category = "vintagethief"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = false
ENT.bNoPersist = true


if (SERVER) then
	
	--function ENT:SpawnFunction(entity, trace)
	--	local wcollectorent = ents.Create("ix_wcollector")
	--	entity:GetPos 
	--end

	function ENT:Initialize()

		self:SetNetVar("wamount", 0)

		self:SetModel("models/props_wasteland/laundry_basket001.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		self.nextUseTime = 0

		self.timer_name = "watertimer" .. self:EntIndex()

		--timer
		local conf_time = ix.config.Get("watertimer")
		local water_n = 0
		local conf_limit = ix.config.Get("waterlimit")
		local conf_tick = ix.config.Get("watertick")

		timer.Create( self.timer_name, conf_time, 0, function()

			if water_n >= conf_limit then
				water_n = conf_limit
			else
				water_n = water_n + conf_tick
			end

			self:SetNetVar("wamount", water_n)

		end)

	end

	local PLUGIN = PLUGIN
	function ENT:StartTouch(entity)

		local item = nil

		if isfunction(entity.GetItemTable) then
			item = entity:GetItemTable()
		else
			return
		end
		print(item.uniqueID)
		for k,v in pairs(PLUGIN.emptycont) do
			if item.uniqueID == k then
				local capacity = v
				if self:GetNetVar("wamount") >= capacity then
					self:SetNetVar("wamount", self:GetNetVar("wamount") - capacity)
					
					entity:Remove()

					local fixpos = self:GetPos() + Vector(0, 0, 30)

					ix.item.Spawn(PLUGIN.fullcont[k], fixpos)

				end
			end
		end
	end

	function ENT:OnRemove()
		timer.Remove(self.timer_name)
	end

else

	function ENT:Draw()

		local conf_limit = ix.config.Get("waterlimit")

		local amount = (self:GetNetVar("wamount") .. "/" .. conf_limit)

		self:DrawModel()
		local fixedAng = self:GetAngles()
		fixedAng:RotateAroundAxis( self:GetRight(), -90 )
		fixedAng:RotateAroundAxis( self:GetForward(), 90 )
		-- text showing waterlevel over model
		if self:GetPos():Distance(LocalPlayer():GetPos()) >= 512 then return end

		local fixedPos = self:GetPos() + self:GetUp() * 5 + self:GetRight() * 5 + self:GetForward() * 26
		cam.Start3D2D(fixedPos, fixedAng, 0.1)
			draw.RoundedBox(4, 0, 0, 100, 100, Color(0,0,0,225))
			draw.SimpleText( "Количество воды:", "Default", 100, 0, Color( 255, 255, 255, 155 ), TEXT_ALIGN_CENTER)
			draw.SimpleText( amount, "Default", 100, 42, Color( 255, 255, 255, 155 ), TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end

end