ITEM.name = "Легкая импульсная винтовка CCA"
ITEM.description = "Винтовка, поступившая сотрудникам Гражданской Обороны на вооружение от Сверхнадзора. Очень эргономичное и надежное оружие."
ITEM.model = "models/weapons/c_ordinalriflearccw.mdl"
ITEM.class = "arccw_rifle"
ITEM.weaponCategory = "primary"
ITEM.rarity = 2
ITEM.width = 3
ITEM.height = 2
ITEM.hasLock = true
ITEM.impulse = true
ITEM.iconCam = {
	pos = Vector(-9, 200, 2),
	ang = Angle(0, 270, 0),
	fov = 8.8235294117647,
}
ITEM.Attack = 12
ITEM.DistanceSkillMod = {
	[1] = 5,
	[2] = 3,
	[3] = 3,
	[4] = -2
}
ITEM.Info = {
	Type = nil,
	Skill = "impulse",
	Distance = {
		[1] = 5,
		[2] = 3,
		[3] = 3,
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


