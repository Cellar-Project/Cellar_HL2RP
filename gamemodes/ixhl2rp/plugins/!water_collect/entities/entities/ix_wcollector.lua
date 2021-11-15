
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

	local emptycont = {
		["empty_can"] = 6,
		["empty_glass_bottle"] = 8,
		["empty_jug"] = 16,
		["empty_plastic_bottle"] = 12,
		["empty_plastic_can"] = 12,
		["empty_tin_can"] = 6
	}

	function ENT:Initialize()

		self:SetNetVar("wamount", 0)

		self:SetModel("models/props_wasteland/laundry_basket001.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		self.nextUseTime = 0

		self.timer_name = "watertimer"..self:EntIndex()

		--timer
		local conf_time = ix.config.Get("watertimer")
		local water_n = 0

		timer.Create( self.timer_name, conf_time, 0, function()

			local conf_limit = ix.config.Get("waterlimit")
			local conf_tick = ix.config.Get("watertick")
		
			if water_n <= conf_limit then
				water_n = water_n + conf_tick
			else
				water_n = conf_limit
			end
			
			self:SetNetVar("wamount", water_n)

		end)

	end

	function ENT:OnRemove()
		timer.Remove(self.timer_name)
	end

else

	function ENT:Draw()

		local amount = self:GetNetVar("wamount")

		self:DrawModel()
		-- text showing waterlevel over model
		if self:GetPos():Distance(LocalPlayer():GetPos()) >= 1000 then return end
		
		local pos = self:GetPos()
		local ang = self:GetAngles()
		--ang:RotateAroundAxis(ang:Right(), -90)
		ang.y = LocalPlayer():EyeAngles().y - 90 -- make it act like a sprite and look at the player

		cam.Start3D2D(pos, ang, 1)
			draw.SimpleTextOutlined(amount, "Default", 0, -800, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
		cam.End3D2D()	
	end

end