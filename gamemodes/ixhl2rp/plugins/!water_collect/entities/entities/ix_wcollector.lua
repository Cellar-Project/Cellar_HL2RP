
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
		--local wcollectorent = ents.Create("ix_wcollector")
		--entity:GetPos -

	--	return entity

	function ENT:Initialize()

		self:SetModel("models/props_wasteland/laundry_basket001.mdl")
		self:SetSolid(SOLD_VPHYSIC)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		self.nextUseTime = 0

		--timer
		local conf_time = ix.config.Get("watertimer")

		timer.Create( watertimer, conf_time, 0, function(WaterDrip) )

		function WaterDrip()

			local conf_limit = ix.config.Get("waterlimit")
			local conf_tick = ix.config.Get("watertick")
			local water_n = 0

			if water_n <= conf_limit then
				water_n = water_n + conf_tick
			end
			print(water_n)
		end

	end

	function ENT:OnRemove()
		timer.Remove("watertimer")
	end

end