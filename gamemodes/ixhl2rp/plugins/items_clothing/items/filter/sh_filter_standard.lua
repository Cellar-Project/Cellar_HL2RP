ITEM.name = "Довоенный фильтр"
ITEM.description = "Этот фильтр, похоже, был вытащен из сырого арсенала еще до Семичасовой войны. От него так и несет ржавчиной, а в противогаз то и дело будут попадать пылинки от его древности, но, в целом, не на долго его хватит."
ITEM.model = Schema.assets.Model("models/vintagethief/items/filter.mdl", "models/props_junk/garbage_metalcan001a.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.filterQuality = 100
ITEM.iconCam = ITEM.model == "models/vintagethief/items/filter.mdl" and {
	pos = Vector(184.87512207031, 155.2127532959, 113.55197906494),
	ang = Angle(25, 220, 0),
	fov = 1.0687235760102,
} or false
