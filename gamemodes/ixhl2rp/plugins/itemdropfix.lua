PLUGIN.name = "Item Drop Fix"
PLUGIN.description = "Prevents dropped items from spawning inside the player and ending up on their head."
PLUGIN.author = "maxxoft"


if SERVER then
	local PLAYER = FindMetaTable("Player")

	function PLAYER:GetItemDropPos(entity)
		local data = {}
		local trace

		data.start = self:GetShootPos()
		data.endpos = self:GetShootPos() + self:GetAimVector() * 86
		data.filter = self

		-- Ignore the currently equipped weapon so the hull trace doesn't stop on the viewmodel
		local weapon = self:GetActiveWeapon()
		if IsValid(weapon) then
			if istable(data.filter) then
				table.insert(data.filter, weapon)
			else
				data.filter = {data.filter, weapon}
			end
		end

		if IsValid(entity) then
			if istable(data.filter) then
				table.insert(data.filter, entity)
			else
				data.filter = {data.filter, entity}
			end

			local mins, maxs = entity:GetRotatedAABB(entity:OBBMins(), entity:OBBMaxs())
			data.mins = mins
			data.maxs = maxs
			trace = util.TraceHull(data)
		else
			trace = util.TraceLine(data)

			data.start = trace.HitPos
			data.endpos = data.start + trace.HitNormal * 48
			trace = util.TraceLine(data)
		end

		local hitPos = trace.HitPos

		local playerPos = self:GetPos()
		local hullMin, hullMax = self:WorldSpaceAABB()

		if hitPos:WithinAABox(hullMin, hullMax) then
			local dir = hitPos - playerPos
			dir.z = 0

			if dir:Length2DSqr() < 0.0001 then
				dir = self:GetForward()
				dir.z = 0
			end

			dir:Normalize()
			hitPos = playerPos + dir * 40
			hitPos.z = trace.HitPos.z
		end

		return hitPos
	end
end
