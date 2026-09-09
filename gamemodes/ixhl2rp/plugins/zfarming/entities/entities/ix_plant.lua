ENT.Type = "anim"
ENT.Author = "maxxoft"
ENT.PrintName = "Растение"
ENT.Description = "Посаженное растение"
ENT.Spawnable = false
ENT.PopulateEntityInfo = true

if (SERVER) then

	local PLUGIN = PLUGIN

	function ENT:Initialize()
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetCollisionBounds(Vector(-3, -3, -3), Vector(3, 3, 3))
		self:PhysicsInit(SOLID_BBOX)

		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
			physicsObject:EnableMotion(false)
		end

		self:SetNetVar("health", 10)
		self:SetGrowthPoints(0)
		self:SetPhase(1)
		self:SetModel(PLUGIN.growModels[math.random(#PLUGIN.growModels)])

		self.timerName = "phasetimer" .. self:EntIndex()
		self:SyncLifecycle()
	end

	function ENT:GrowthTick()
		local phaseMaxPoints = ix.config.Get("phaseMaxPoints")
		local phaseRate = ix.config.Get("phaseRate")

		self:SetGrowthPoints(self:GetGrowthPoints() + phaseRate)
		self:SetNetVar("health", self:GetNetVar("health", 10) - .5)

		if (self:GetGrowthPoints() >= phaseMaxPoints) then
			self:SetPhase(self:GetPhase() + 1)
			self:SetGrowthPoints(0)
		end

		self:SyncLifecycle()
		PLUGIN:SaveData()
	end

	-- Derives grown/dead and the growth timer from health and phase. Used after
	-- every tick and after restoring a plant from disk, so a saved plant comes
	-- back in the same lifecycle state it was in when saved.
	function ENT:SyncLifecycle()
		if (self:GetNetVar("health", 10) <= 0 or self:GetNetVar("dead", false)) then
			self:Die()
		elseif (self:GetPhase() >= ix.config.Get("phases")) then
			self:EndGrowth()
		else
			self:SetNetVar("grown", false)
			self:StartGrowthTimer()
		end
	end

	function ENT:StartGrowthTimer()
		timer.Create(self.timerName, ix.config.Get("phaseTime"), 0, function()
			if (!IsValid(self)) then
				timer.Remove(self.timerName)
				return
			end

			self:GrowthTick()
		end)
	end

	function ENT:OnSelectHarvest(client)
		if not self:GetNetVar("grown") then return end
		if client:EyePos():Distance(self:GetPos()) > 90 then return end
		if !self.item then return end

		local character = client:GetCharacter()
		local inventory = character:GetInventory()
		local skill = math.max(character:GetSkillModified("farming") or 0, 0)
		local modifier = math.Clamp(skill / 10, .1, 1)
		local productAmount = math.floor((self.item.maxAmount or 1) * modifier)
		local product = self.product or self.item.product

		if (product) then
			while productAmount > 0 do
				if not inventory:Add(product) then break end
				productAmount = productAmount - 1
			end

			for _ = 1, productAmount do
				ix.item.Spawn(product, self:GetPos() + Vector(0, 0, 2))
			end
		end

		for _ = 1, math.random(0, math.floor(skill)) do
			ix.item.Spawn(self:GetPlantClass(), self:GetPos() + Vector(0, 2, 3))
		end

		self:Remove()
	end

	function ENT:OnSelectDestroy(client)
		if client:EyePos():Distance(self:GetPos()) > 90 then return end

		self:Remove()
		client:NotifyLocalized("plantDestroyed")
	end

	function ENT:OnSelectWater(client)
		local curHealth = self:GetNetVar("health", 10)
		if curHealth >= 10 then
			client:NotifyLocalized("wateringNotNeeded")
			return
		end
		if client:EyePos():Distance(self:GetPos()) > 90 then return end

		local points = 0
		local inventory = client:GetCharacter():GetInventory()

		for k, item in pairs(inventory:GetItems()) do
			if item.base == "base_drink" then
				local basePoints = PLUGIN.waterItems[item.uniqueID]
				if basePoints then
					local maxUses = item.dUses or 1
					points = points + basePoints * (item:GetData("uses", maxUses) / maxUses) -- TODO: add skill bonus
					self:SetNetVar("health", math.Clamp(curHealth + points, 0, 10))

					local junk = item.junk or PLUGIN.itemReplacers[item.uniqueID]
					item:Remove()

					if (junk) then
						inventory:Add(junk)
					end

					client:NotifyLocalized("plantWatered")
					client:GetCharacter():DoAction("farmingWater")
					return
				end
			end
		end
		client:NotifyLocalized("wateringNoItem")
	end

	function ENT:SetPlantClass(class)
		self.item = ix.item.Get(class)

		if (self.item) then
			self.product = self.product or self.item.product

			if (!self:GetNetVar("name") and self.item.plantName) then
				self:SetPlantName(self.item.plantName)
			end
		end
	end

	function ENT:SetPlantName(name)
		self:SetNetVar("name", name)
	end

	function ENT:GetPlantClass()
		return self.item and self.item.uniqueID
	end

	function ENT:SetPhase(iPhase)
		self.phase = math.Clamp(iPhase, 0, ix.config.Get("phases"))
	end

	function ENT:GetPhase()
		return self.phase
	end

	function ENT:SetGrowthPoints(iPoints)
		self.growthPoints = iPoints
	end

	function ENT:GetGrowthPoints()
		return self.growthPoints
	end

	function ENT:StopGrowthTimer()
		if (self.timerName and timer.Exists(self.timerName)) then
			timer.Remove(self.timerName)
		end
	end

	function ENT:EndGrowth()
		self:SetNetVar("grown", true)
		self:StopGrowthTimer()
	end

	function ENT:Die()
		self:SetNetVar("grown", false)
		self:SetNetVar("dead", true)
		self:StopGrowthTimer()
	end

	function ENT:OnRemove()
		self:StopGrowthTimer()
	end

else

	function ENT:OnPopulateEntityInfo(tooltip)
		local description

		if (self:GetNetVar("grown")) then
			description = L"plantGrown"
		elseif self:GetNetVar("dead") then
			description = L"plantDead"
		else
			description = L"plantNotGrown"
		end

		local title = tooltip:AddRow("name")
		title:SetText(self:GetPlantName() or self.PrintName)
		title:SetImportant()
		title:SizeToContents()

		local panel = tooltip:AddRow("description")
		panel:SetText(description)
		panel:SizeToContents()

		local healthbar = tooltip:Add("EditablePanel")
		healthbar:Dock(TOP)
		healthbar:SetHeight(3)
		healthbar.Paint = function(this, w, h)
			if self:GetNetVar("dead") then return end
			surface.SetDrawColor(Color(23, 204, 47))
			surface.DrawRect(0, 0, w * (self:GetNetVar("health") / 10), 2)
		end
	end

	function ENT:GetEntityMenu()
		local options = {
			[L"menuDestroy"] = function()
				ix.menu.NetworkChoice(self, "Destroy")
			end
		}

		if self:GetNetVar("grown") then
			options[L"menuHarvest"] = function()
				ix.menu.NetworkChoice(self, "Harvest")
			end
		end

		if self:GetNetVar("health") < 10 then
			options[L"menuWater"] = function()
				ix.menu.NetworkChoice(self, "Water")
			end
		end

		return options
	end

end

do

	function ENT:GetPlantName()
		return self:GetNetVar("name")
	end

end
