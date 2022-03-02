ITEM.name = "Base Farming"
ITEM.description = "Небольшая упаковка с семенами."
ITEM.model = Model("models/props_lab/box01a.mdl")
ITEM.category = "categoryFarming"
ITEM.width = 1
ITEM.height = 1
ITEM.rarity = 1
ITEM.surfaces = {
	[MAT_DIRT] = true,
	[MAT_GRASS] = true,
	[MAT_FOLIAGE] = true
}


ITEM.functions.Plant = {
	name = "Посадить",
	icon = "icon16/accept.png",
	OnRun = function(item)
		local client = item.player
		local tr = client:GetEyeTraceNoCursor()

		if (tr.Hit and surfaces[tr.MatType]) then
			if client:EyePos():Distance(tr.HitPos) > 80 then
				client:Notify("Поверхность слишком далеко.")
				return
			end

			local plant = ents.Create("ix_plant")
			plant:SetClass(item.seedclass)
			plant:SetPos(tr.HitPos[3] - 2)
			plant:Spawn()
		end
	end
}