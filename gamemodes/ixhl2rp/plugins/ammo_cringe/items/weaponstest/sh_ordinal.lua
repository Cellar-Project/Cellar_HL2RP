ITEM.name = "Пулемет Ординала"
ITEM.description = "Тяжелый пулемет производства Вселенского Союза, предназначенный для использования отрядами подавления Солдат Патруля."
ITEM.model = "models/weapons/w_suppressor.mdl"
ITEM.class = "arccw_ordinal"
ITEM.weaponCategory = "primary"
ITEM.rarity = 2
ITEM.width = 5
ITEM.height = 2
ITEM.hasLock = true
ITEM.impulse = true
ITEM.iconCam = {
	pos = Vector(-9, 200, 2),
	ang = Angle(0, 270, 0),
	fov = 8.8235294117647,
}
ITEM.Attack = 18
ITEM.DistanceSkillMod = {
	[1] = 5,
	[2] = 3,
	[3] = 1,
	[4] = -2
}
ITEM.Info = {
	Type = nil,
	Skill = "impulse",
	Distance = {
		[1] = 5,
		[2] = 3,
		[3] = 1,
		[4] = -2
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 60,
		Shock = {100, 1900},
		Blood = {30, 360},
		Bleed = 5
	}
}


