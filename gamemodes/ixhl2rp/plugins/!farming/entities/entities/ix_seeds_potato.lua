ENT.Type = "anim"
ENT.Author = "Vintage Thief"
ENT.PrintName = "Семена картошки"
ENT.Description = "Небольшая упаковка с семенами."
ENT.Spawnable = false
ENT.AdminSpawnable = true

if (SERVER) then

    local PLUGIN = PLUGIN

    function ENT:Initialize()
        self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetSolid(SOLID_VPHYSICS)

        local physicObject = self:GetPhysicsObject()

        if (IsValid(physicsObject)) then
            physicsObject:Wake()
            physicsObject:EnableMotion(true)
        end
        
        self.nextUse = 0

	    self.timer_name = "phasetimer" .. self:EntIndex()

	    local conf_phasetime = ix.config.Get("phasetime")
	    local growth_n = 0
	    local phase = 0
	    self:SetNetVar("grown", 0)

	    timer.Create( self.timer_name, conf_phasetime, 0, function()
	
	    	local conf_phaseamount = ix.config.Get("phaseamount")
	    	local conf_phaserate = ix.config.Get("phaserate")
	    	local conf_phases = ix.config.Get("phases")
			-- for в списке текстур. ибо не валид
	    	if self:OnGround() and (SurfaceInfo:GetMaterial() == ("de_cbble/grassdirt_blend" or "nature/blenddirtdirt001a" or "highdef/metro2033/floor/floor_beton_pol_dirt3")) then
		    	growth_n = math.Clamp( growth_n + conf_phaserate, 0, conf_phaseamount)
		    	phase = 1
		    	if growth_n == conf_phaseamount then
		    		phase = math.Clamp( phase + 1, 0, conf_phases)
		    		if phase == conf_phases then
			    		self:SetNetVar("grown", 1)
			    	end
		    	end
	    	end
	
	    	for k, v in ipairs(PLUGIN.growmodel) do
	    		self:SetModel( v )
	    	end
      end)
    end

    function ENT:SetSeedItem(item)
        self:SetNetVar("item", item)
    end

	function ENT:Use( activator )

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
				entity:Remove()

				local amount = math.random(3, 6)

				for i=0,amount do
					ix.item.Spawn(result, fixpos)
				end
			end
		end
	end

	function ENT:OnRemove()
		timer.Remove(self.timer_name)
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