local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	self:SaveSeed()
end

function PLUGIN:LoadData()
	local data = self:GetData()

	if (data) then
		for _, v in ipairs(data) do
			local entity = ents.Create("ix_seeds_potato")
			entity:SetPos(v[1])
			entity:SetAngles(v[2])
			entity:SetModel(v[8] or "models/props_lab/citizenradio.mdl")
			entity:Spawn()
			entity:SetSeedItem(v[7])

			local physObject = entity:GetPhysicsObject()

			if (IsValid(physObject)) then
				physObject:EnableMotion(v[8] and false or true)
			end
		end
	end
end