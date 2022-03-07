
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Forcefield"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PhysgunDisabled = true
ENT.bNoPersist = true
ENT.Editable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Mode")
	self:NetworkVar("Entity", 0, "Dummy")
	self:NetworkVar("String", 0, "Access", {KeyName = "Access", Edit = {type = "String", order = 1}})
end

local MODE_ALLOW_ALL = 1
local MODE_ALLOW_NONE = 2
local MODES = {
	{
		function(client)
			return false
		end,
		"деактивировано"
	},
	{
		function(client)
			return true
		end,
		"активировано"
	},
	{
		function(client)
			return true
		end,
		"вход по доступам"
	}
}

if (SERVER) then

	function ENT:SpawnFunction(client, trace)
		local angles = (client:GetPos() - trace.HitPos):Angle()
		angles.p = 0
		angles.r = 0
		angles:RotateAroundAxis(angles:Up(), 270)

		local entity = ents.Create("ix_forcefield")
		entity:SetPos(trace.HitPos + Vector(0, 0, 40))
		entity:SetAngles(angles:SnapTo("y", 90))
		entity:Spawn()
		entity:Activate()
		entity:SetAccess("cmbMpfAll")

		Schema:SaveForceFields()
		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_fence01b.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)

		local data = {}
			data.start = self:GetPos() + self:GetRight() * -16
			data.endpos = self:GetPos() + self:GetRight() * -480
			data.filter = self
		local trace = util.TraceLine(data)

		local angles = self:GetAngles()
		angles:RotateAroundAxis(angles:Up(), 90)

		self.dummy = ents.Create("prop_physics")
		self.dummy:SetModel("models/props_combine/combine_fence01a.mdl")
		self.dummy:SetPos(trace.HitPos)
		self.dummy:SetAngles(self:GetAngles())
		self.dummy:Spawn()
		self.dummy.PhysgunDisabled = true
		self:DeleteOnRemove(self.dummy)

		local verts = {
			{pos = Vector(0, 0, -25)},
			{pos = Vector(0, 0, 150)},
			{pos = self:WorldToLocal(self.dummy:GetPos()) + Vector(0, 0, 150)},
			{pos = self:WorldToLocal(self.dummy:GetPos()) + Vector(0, 0, 150)},
			{pos = self:WorldToLocal(self.dummy:GetPos()) - Vector(0, 0, 25)},
			{pos = Vector(0, 0, -25)}
		}

		self:PhysicsFromMesh(verts)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		self:SetCustomCollisionCheck(true)
		self:EnableCustomCollisions(true)
		self:SetDummy(self.dummy)

		physObj = self.dummy:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		self:SetMoveType(MOVETYPE_NOCLIP)
		self:SetMoveType(MOVETYPE_PUSH)
		self:MakePhysicsObjectAShadow()
		self:SetMode(MODE_ALLOW_ALL)
	end

	function ENT:StartTouch(entity)
		if (!self.buzzer) then
			self.buzzer = CreateSound(entity, "ambient/machines/combine_shield_touch_loop1.wav")
			self.buzzer:Play()
			self.buzzer:ChangeVolume(0.8, 0)
		else
			self.buzzer:ChangeVolume(0.8, 0.5)
			self.buzzer:Play()
		end

		self.entities = (self.entities or 0) + 1
	end

	function ENT:EndTouch(entity)
		self.entities = math.max((self.entities or 0) - 1, 0)

		if (self.buzzer and self.entities == 0) then
			self.buzzer:FadeOut(0.5)
		end
	end

	function ENT:OnRemove()
		if (self.buzzer) then
			self.buzzer:Stop()
			self.buzzer = nil
		end

		if (!ix.shuttingDown and !self.ixIsSafe) then
			Schema:SaveForceFields()
		end
	end

	function ENT:Use(activator)
		if ((self.nextUse or 0) < CurTime()) then
			self.nextUse = CurTime() + 1.5
		else
			return
		end

		if (activator:IsCombine() and activator:GetCharacter():HasIDAccess(self:GetAccess())) then
			self:SetMode(self:GetMode() + 1)

			if (self:GetMode() > #MODES) then
				self:SetMode(1)

				self:SetSkin(1)
				self.dummy:SetSkin(1)
				self:EmitSound("npc/turret_floor/die.wav")
			else
				self:SetSkin(0)
				self.dummy:SetSkin(0)
			end

			self:EmitSound("buttons/combine_button5.wav", 140, 100 + (self:GetMode() - 1) * 15)
			activator:Notify("Режим установлен на: " .. MODES[self:GetMode()][2])

			Schema:SaveForceFields()
		else
			self:EmitSound("buttons/combine_button3.wav")
		end
	end

	-- hook.Add("ShouldCollide", "ix_forcefields", function(a, b)
	-- 	local forcefield
	-- 	local entity

	-- 	if (IsValid(a) and a:GetClass() == "ix_forcefield") then
	-- 		forcefield = a
	-- 		entity = b
	-- 	elseif (IsValid(b) and b:GetClass() == "ix_forcefield") then
	-- 		forcefield = b
	-- 		entity = a
	-- 	end

	-- 	if (IsValid(entity)) then
	-- 		local client = entity:IsPlayer() and entity or entity:GetNetVar("player")

	-- 		if (IsValid(client)) then
	-- 			local mode = forcefield:GetMode() or MODE_ALLOW_ALL

	-- 			if mode == 3 then
	-- 				return !client:GetCharacter():HasIDAccess(forcefield:GetAccess())
	-- 			end

	-- 			return istable(MODES[mode]) and MODES[mode][1](client)
	-- 		else
	-- 			return forcefield:GetMode() != MODE_ALLOW_NONE
	-- 		end
	-- 	end
	-- end)
else
	local SHIELD_MATERIAL = ix.util.GetMaterial("effects/combineshield/comshieldwall3")

	function ENT:Initialize()
		local data = {}
			data.start = self:GetPos() + self:GetRight() * -16
			data.endpos = self:GetPos() + self:GetRight() * -480
			data.filter = self
		self:EnableCustomCollisions(true)

		timer.Simple(1, function()
			local dummy = self:GetDummy()

			local verts = {
				{pos = Vector(0, 0, -25)},
				{pos = Vector(0, 0, 150)},
				{pos = self:WorldToLocal(dummy:GetPos()) + Vector(0, 0, 150)},
				{pos = self:WorldToLocal(dummy:GetPos()) + Vector(0, 0, 150)},
				{pos = self:WorldToLocal(dummy:GetPos()) - Vector(0, 0, 25)},
				{pos = Vector(0, 0, -25)}
			}

			self:PhysicsFromMesh(verts)
		end)
	end

	function ENT:Draw()
		self:DrawModel()

		if (self:GetMode() == 1) then
			return
		end

		local angles = self:GetAngles()
		local matrix = Matrix()
		matrix:Translate(self:GetPos() + self:GetUp() * -40)
		matrix:Rotate(angles)

		render.SetMaterial(SHIELD_MATERIAL)

		local dummy = self:GetDummy()

		if (IsValid(dummy)) then
			local vertex = self:WorldToLocal(dummy:GetPos())
			self:SetRenderBounds(vector_origin, vertex + self:GetUp() * 150)

			cam.PushModelMatrix(matrix)
				self:DrawShield(vertex)
			cam.PopModelMatrix()

			matrix:Translate(vertex)
			matrix:Rotate(Angle(0, 180, 0))

			cam.PushModelMatrix(matrix)
				self:DrawShield(vertex)
			cam.PopModelMatrix()
		end
	end

	function ENT:DrawShield(vertex)
		mesh.Begin(MATERIAL_QUADS, 1)
			mesh.Position(vector_origin)
			mesh.TexCoord(0, 0, 0)
			mesh.AdvanceVertex()

			mesh.Position(self:GetUp() * 190)
			mesh.TexCoord(0, 0, 3)
			mesh.AdvanceVertex()

			mesh.Position(vertex + self:GetUp() * 190)
			mesh.TexCoord(0, 3, 3)
			mesh.AdvanceVertex()

			mesh.Position(vertex)
			mesh.TexCoord(0, 3, 0)
			mesh.AdvanceVertex()
		mesh.End()
	end
end

do
	hook.Add("ShouldCollide", "ix_forcefields", function(a, b)
		local forcefield
		local entity

		if (IsValid(a) and a:GetClass() == "ix_forcefield") then
			forcefield = a
			entity = b
		elseif (IsValid(b) and b:GetClass() == "ix_forcefield") then
			forcefield = b
			entity = a
		end

		if (IsValid(entity)) then
			local client = entity:IsPlayer() and entity or entity:GetNetVar("player")

			if (IsValid(client)) then
				local mode = forcefield:GetMode() or MODE_ALLOW_ALL

				if mode == 3 then
					return !client:GetCharacter():HasIDAccess(forcefield:GetAccess())
				end

				return istable(MODES[mode]) and MODES[mode][1](client)
			else
				return forcefield:GetMode() != MODE_ALLOW_NONE
			end
		end
	end)
end