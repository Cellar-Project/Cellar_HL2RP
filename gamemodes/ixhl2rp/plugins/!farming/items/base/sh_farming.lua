ITEM.name = "Base Farming"
ITEM.description = "Небольшая упаковка с семенами."
ITEM.model = Model("models/props_lab/box01a.mdl")
ITEM.category = "categoryFarming"
ITEM.width = 1
ITEM.height = 1
ITEM.rarity = 1
ITEM.dropamount = math.random(1, 4)

ITEM:Hook("drop", function(item)
	local seed = ents.Create("ix_seeds_" .. item.seedclass)
	seed:SetSeedItem(item.uniqueID)
	seed:SetModel(item.model)
	seed:SetPos(item.player:GetItemDropPos(seed))
	seed:Spawn()

	return true
end)