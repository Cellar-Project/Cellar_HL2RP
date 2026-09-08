ITEM.name = "Фильтр Mk. II"
ITEM.description = "Эти фильтры собираются на заказ силами Сверхнадзора для солдат Патруля по всему миру. Примечательно то, что в сплаве металла, который и формирует этот фильтр, находится тот самый внеземной металл, что делает этот фильтр довольно тяжелым, но при этом и одним из самых эффективных."
ITEM.model = Schema.assets.Model("models/vintagethief/items/filter.mdl", "models/props_junk/garbage_metalcan001a.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.skin = ITEM.model == "models/vintagethief/items/filter.mdl" and 3 or 0
ITEM.rarity = 3
ITEM.filterQuality = 5000
ITEM.iconCam = ITEM.model == "models/vintagethief/items/filter.mdl" and {
	pos = Vector(184.87512207031, 155.2127532959, 113.55197906494),
	ang = Angle(25, 220, 0),
	fov = 1.0687235760102,
} or false
