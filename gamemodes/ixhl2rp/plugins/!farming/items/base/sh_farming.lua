ITEM.name = "Base Farming"
ITEM.description = "Небольшая упаковка с семенами."
ITEM.model = Model("models/props_lab/box01a.mdl")
ITEM.category = "categoryFarming"
ITEM.width = 1
ITEM.height = 1
ITEM.rarity = 1
ITEM.dropamount = math.random(1, 4)


if (SERVER) then

	self.timer_name = "phasetimer" .. self:EntIndex()

	local conf_phasetime = ix.config.Get("phasetime")
	local growth_n = 0
	local phase = 0
	self:SetNetVar("grown", 0)

	timer.Create( self.timer_name, conf_phasetime, 0, function()
	
		local conf_phaseamount = ix.config.Get("phaseamount")
		local conf_phaserate = ix.config.Get("phaserate")
		local conf_phases = ix.config.Get("phases")


		--tracing ground
		local pos = self:GetPos()
		local groundhit = false 
		local tr = util.TraceLine( {
			start = pos,
			endpos = pos + self:GetUp() * -16,
			filter = self
	})

	if self:OnGround() and (SurfaceInfo:GetMaterial() == ("de_cbble/grassdirt_blend" or "nature/blenddirtdirt001a" or "highdef/metro2033/floor/floor_beton_pol_dirt3")) then
		growth_n = math.Clamp( growth_n + conf_phaserate, 0, phase_amount)
		phase = 1
		if growth_n = conf_phaseamount then
			phase = math.Clamp( phase + 1, 0, conf_phases)
			if phase = conf_phases then
				self:SetNetVar("grown", 1)
			end
		end
	end

	for k, v in pairs(self.growmodel) do
		ITEM:SetModel( v )
	end


	local PLUGIN = PLUGIN
	function ITEM:Use( activator )

		local item = nil 

		local result = PLUGIN.seedplant[item.uniqueID]

		if isfunction(entity.GetItemTable) then
			item = entity:GetItemTable()
		else
			return 
		end

		if self:GetNetVar("grown") == 1 then
			if( activator:IsPlayer() ) then
			
				local fixpos = self:GetPos() + Vector(0, 0, 30)
				self:SetNetVar("grown", 0)
				item:Remove()

				for i=0,self.dropamount do
					ix.item.Spawn(result, fixpos)
				end
			end
		end
	end

	function ITEM:OnRemove()
		timer.Remove(self.timer_name)
	end

else
	
	function ITEM:Draw()

	end

end