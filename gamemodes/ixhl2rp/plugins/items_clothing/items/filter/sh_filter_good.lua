ITEM.name = "Фильтр Mk. I"
ITEM.description = "Эти фильтры собирают на заводах Сити-3. Виднеется приятная матовая поверхность и множество отсеков для выхода отфильтрованного воздуха. На боку этого фильтра виднеется очень маленькая ватермарка, которая гласит: \"Сделано в Сити-3\". Обычно подобные фильтры используют сотрудники Гражданской Обороны."
ITEM.model = Schema.assets.Model("models/vintagethief/items/filter.mdl", "models/props_junk/garbage_metalcan001a.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.skin = ITEM.model == "models/vintagethief/items/filter.mdl" and 2 or 0
ITEM.rarity = 2
ITEM.filterQuality = 2500
ITEM.iconCam = ITEM.model == "models/vintagethief/items/filter.mdl" and {
	pos = Vector(184.87512207031, 155.2127532959, 113.55197906494),
	ang = Angle(25, 220, 0),
	fov = 1.0687235760102,
} or false
