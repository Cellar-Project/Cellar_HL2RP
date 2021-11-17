ITEM.name = "Униформа офицера-медика ГО"
ITEM.description = "Униформа офицера-медика Гражданской Обороны."
-- ITEM.genderReplacement = {
-- 	[GENDER_MALE] = "models/cellar/characters/metropolice/male.mdl",
-- 	[GENDER_FEMALE] = "models/cellar/characters/metropolice/female.mdl"
-- }
ITEM.Stats = {
	[HITGROUP_GENERIC] = 0,
	[HITGROUP_HEAD] = 0,
	[HITGROUP_CHEST] = 10,
	[HITGROUP_STOMACH] = 5,
	[4] = 5,
	[5] = 5,
}
ITEM.ReplaceOnDeath = "Униформа медика с бронежилетом"
ITEM.uniform = 1
ITEM.primaryVisor = Vector(0.75, 0.2, 0.1)
ITEM.secondaryVisor = Vector(0.75, 0.2, 0.1)
ITEM.specialization = "m"
ITEM.bodyGroups = {
	[0] = 0,
	[1] = 1,
	[2] = 1,
	[3] = 0,
	[4] = 1,
	[5] = 0,
	[6] = 4,
	[7] = 0,
	[8] = 0,
	[9] = 0
}