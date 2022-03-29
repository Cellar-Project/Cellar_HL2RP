ITEM.name = "SPAS-12"
ITEM.description = "Тяжелый импульсный дробовик производства Вселенского Союза. Очень разрушительное оружие в тесных пространствах."
ITEM.model = "models/weapons/w_heavyshotgun.mdl"
ITEM.class = "arccw_heavyshotgun"
ITEM.weaponCategory = "primary"
ITEM.width = 3
ITEM.height = 1
ITEM.hasLock = true
ITEM.impulse = true
ITEM.iconCam = {
	pos = Vector(0, 200, 1),
	ang = Angle(0, 270, 0),
	fov = 10
}

ITEM.Attack = 13
ITEM.DistanceSkillMod = {
	[1] = 8,
	[2] = 1,
	[3] = -3,
	[4] = -6
}
ITEM.Info = {
	Type = nil,
	Skill = "impulse",
	Distance = {
		[1] = 8,
		[2] = 1,
		[3] = -3,
		[4] = -6
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 34,
		Shock = {600, 30000},
		Blood = {220, 800},
		Bleed = 5
	}
}