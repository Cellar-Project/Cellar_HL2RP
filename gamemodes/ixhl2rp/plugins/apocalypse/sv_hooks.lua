local PLUGIN = PLUGIN

function PLUGIN:CanPlayerEquipItem(client, item, slot)
	if IsValid(client) and client:GetData("zombie", false) then
		return false
	end
end

function PLUGIN:CanPlayerInteractItem(client, action)
	if IsValid(client) and client:GetData("zombie", false) then
		return false
	end
end

function PLUGIN:CanPlayerInteractEntity(client, entity)
	if IsValid(client) and client:GetData("zombie", false) then
		return false
	end
end

function PLUGIN:EntityTraceAttack(attacker, target, trace, dmgInfo)
	local weapon = dmgInfo:GetInflictor()

	if IsValid(weapon) then
		if weapon.IsFists and attacker:GetData("zombie", false) then
			self:InfectPlayer(target:GetPlayer())
		end
	end
end
