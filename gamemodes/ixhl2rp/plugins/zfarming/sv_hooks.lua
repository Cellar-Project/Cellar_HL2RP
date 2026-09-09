local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	local data = {}
	for _, v in ipairs(ents.FindByClass("ix_plant")) do
		data[#data + 1] = {
			v:GetModel(),
			v:GetPos(),
			v:GetAngles(),
			v:GetNetVar("health", 10),
			v:GetNetVar("dead", false),
			v:GetGrowthPoints(),
			v:GetPlantClass(),
			v:GetPhase(),
			v:GetPlantName(),
		}
	end
	self:SetData(data)
end

function PLUGIN:LoadData()
	local data = self:GetData() or {}

	for _, v in ipairs(data) do
		local entity = ents.Create("ix_plant")
		entity:SetPos(v[2])
		entity:SetAngles(v[3])
		entity:Spawn()
		entity:SetModel(v[1] or "models/props/de_train/bush2.mdl")
		entity:SetNetVar("health", v[4])
		entity:SetNetVar("dead", v[5])
		entity:SetGrowthPoints(v[6])
		entity:SetPlantClass(v[7])
		entity:SetPhase(v[8])

		if (v[9]) then
			entity:SetPlantName(v[9])
		end

		if (!entity.item) then
			ErrorNoHalt(string.format("[Farming] Restored plant at %s references unknown seed item '%s'; it cannot be harvested.\n", tostring(v[2]), tostring(v[7])))
		end

		entity:SyncLifecycle()
	end
end
