AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "warmthbox"
ENT.Category = "Helix"
ENT.Spawnable = true

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube4x4x2.mdl")
		self:SetColor(0, 0, 0, 0)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetTrigger(true)
	end

	function ENT:StartTouch(entity)
		if entity:IsPlayer() then
			entity.inWarmth = true
			print("starttouch")
		end
	end

	function ENT:EndTouch(entity)
		if entity:IsPlayer() then
			entity.inWarmth = false
			print("endtouch")
		end
	end
end