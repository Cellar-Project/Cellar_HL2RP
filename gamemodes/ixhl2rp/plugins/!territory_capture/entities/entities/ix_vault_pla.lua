local PLUGIN = PLUGIN


ENT.Type = "anim"
ENT.PrintName = "Vault - PLA"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = false
ENT.bNoPersist = true


if (SERVER) then

	function ENT:Initialize()

		self:SetNetVar("reward_done", false)
		self:SetNetVar("now_time", 0)

		self:SetModel("models/Items/ammocrate_grenade.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		self.nextUseTime = 0

		local conf_time = ix.config.Get("reward_time")

		self.timer_name = "vault_timer" .. self:EntIndex()
		self.timer_name_tick = "vault_timer_tick" .. self:EntIndex()

		timer.Create( self.timer_name, conf_time, 0, function()
			self:SetNetVar("reward_done", true)
		end)

		timer.Create( self.timer_name_tick, 1, 0, function()
			self:SetNetVar("now_time", self:GetNetVar("now_time") + 1)
		end)

	end
	
	local PLUGIN = PLUGIN
	function ENT:Use( activator, caller )
		if not activator:IsPlayer() then return end
		if self:GetNetVar("reward_done") then

			timer.Remove(self.timer_name)

			local char = activator:GetCharacter()
			local pla = 2
			local z_check_metro = ix.config.Get("z_metro")
			local z_check_otabridge = ix.config.Get("z_otabridge")
			local z_check_village = ix.config.Get("z_village")
			local z_check_destroyedvillage = ix.config.Get("z_destroyedvillage")
			local z_check_canalspit = ix.config.Get("z_canalspit")
			local z_check_fisherhouse = ix.config.Get("z_fisherhouse")
			local z_check_mines = ix.config.Get("z_mines")

			if z_check_metro = pla then
			
				local tokens_amount = PLUGIN.loot_tokens.tokens
				char:SetMoney(char:GetMoney() + tokens_amount)

				for k, v in pairs(PLUGIN.loot_ammo) do
					char:GetInventory():Add(k, v)
				end

				for k, v in pairs(PLUGIN.loot_healthkits) do
					char:GetInventory():Add(k, v)
				end
			end
			if z_check_otabridge = pla then
				for k, v in pairs(PLUGIN.loot_ammo) do
					char:GetInventory():Add(k, v)
				end

				for k, v in pairs(PLUGIN.loot_healthkits) do
					char:GetInventory():Add(k, v)
				end
			end
			if z_checkvillage = pla then
				local tokens_amount = PLUGIN.loot_tokens.tokens
				char:SetMoney(char:GetMoney() + tokens_amount)

				for k, v in pairs(PLUGIN.loot_food) do
					char:GetInventory():Add(k, v)
				end

				for k, v in pairs(PLUGIN.loot_drinks) do
					char:GetInventory():Add(k, v)
				end
			end
			if z_check_destroyedvillage = pla then
				for k, v in pairs(PLUGIN.loot_healthkits) do
					char:GetInventory():Add(k, v)
				end

				for k, v in pairs(PLUGIN.loot_seeds) do
					char:GetInventory():Add(k, v)
				end
			end
			if z_check_canalspit = pla then
				local tokens_amount = PLUGIN.loot_tokens.tokens
				char:SetMoney(char:GetMoney() + tokens_amount)

				for k, v in pairs(PLUGIN.loot_garabge) do
					char:GetInventory():Add(k, v)
				end
			end
			if z_check_fisherhouse = pla then
				for k, v in pairs(PLUGIN.loot_food) do
					char:GetInventory():Add(k, v)
				end

				for k, v in pairs(PLUGIN.loot_drinks) do
					char:GetInventory():Add(k, v)
				end
			end
			if z_check_mines = pla then
				local tokens_amount = PLUGIN.loot_tokens.tokens
				char:SetMoney(char:GetMoney() + tokens_amount)

				for k, v in pairs(PLUGIN.loot_metal) do
					char:GetInventory():Add(k, v)
				end
			end
			char:GetPlayer():NotifyLocalized("Вы успешно забрали вашу добычу.")
			timer.Create(self.timer_name, conf_time, 0, fucntion () end))
			self:SetNetVar("reward_done", false)
		else
			char:GetPlayer():NotifyLocalized("Время для получения добычи еще не пришло.")
		end

	function ENT:OnRemove()
		timer.Remove(self.timer_name)
	end

else

	function ENT:Draw()

		local amount = (self:GetNetVar("now_time") .. "/" .. conf_time)

		self:DrawModel()
		local fixedAng = self:GetAngles()
		fixedAng:RotateAroundAxis( self:GetRight(), -90 )
		fixedAng:RotateAroundAxis( self:GetForward(), 90 )
		
		if self:GetPos():Distance(LocalPlayer():GetPos()) >= 512 then return end

		local fixedPos = self:GetPos() + self:GetUp() * 5 + self:GetRight() * 5 + self:GetForward() * 26
		cam.Start3D2D(fixedPos, fixedAng, 0.1)
			draw.RoundedBox(4, 0, 0, 100, 100, Color(0,0,0,225))
			draw.SimpleText( "Готовность:", "Default", 50, 0, Color( 255, 255, 255, 155 ), TEXT_ALIGN_CENTER)
			draw.SimpleText( amount, "Default", 50, 42, Color( 255, 255, 255, 155 ), TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end

end