ITEM.name = "Маска с визором"
ITEM.description = "Стандартная маска-противогаз Гражданской Обороны с визором."
ITEM.model = Model("models/vintagethief/items/cca/mask_03.mdl")
ITEM.rarity = 2
ITEM.bodyGroups = {
	[0] = 1,
	[7] = 4
}
ITEM.Filters = {
	["filter_epic"] = false,
	["filter_good"] = true,
	["filter_medium"] = true,
	["filter_standard"] = false
}
ITEM.Stats = {
	[HITGROUP_GENERIC] = 0,
	[HITGROUP_HEAD] = 5,
	[HITGROUP_CHEST] = 0,
	[HITGROUP_STOMACH] = 0,
	[4] = 0,
	[5] = 0,
}
ITEM.WeaponSkillBuff = 3
ITEM.CPMask = true