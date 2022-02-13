AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "WarmZone"
ENT.Category = "Helix"
ENT.Spawnable = false


if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube4x4x2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)

		self:GetPhysicsObject():Wake()

		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetTrigger(true)
	end

	function ENT:StartTouch(entity)
		if entity:IsPlayer() then
			entity.inWarmth = true
			entity:ChatPrint("Touched ent!")
		end
	end

	function ENT:EndTouch(entity)
		if entity:IsPlayer() then
			entity.inWarmth = false
			entity:ChatPrint("Left ent!")
		end
	end
else
	function ENT:Draw() end
end