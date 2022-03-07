local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	local data
	for _, v in ipairs(ents.FindByClass("ix_plant")) do
		data[#data + 1] = {
			v:GetModel(),
			v:GetPos(),
			v:GetAngles(),
			v:GetClass(),
			v:GetPhase(),
			v:GetGrowthPoints(),
			v.product
		}
	end
end

function PLUGIN:LoadData()
	local data = self:GetData()

	if (data) then
		for _, v in ipairs(data) do
			local entity = ents.Create("ix_plant")
			entity:SetPos(v[2])
			entity:SetAngles(v[3])
			entity:Spawn()
			entity:SetModel(v[1] or "models/props/de_train/bush2.mdl")
			entity:SetClass(v[4])
			entity:SetPhase(v[5])
			entity:GetGrowthPoints(v[6])
			entity.product = v.product
		end
	end
end
