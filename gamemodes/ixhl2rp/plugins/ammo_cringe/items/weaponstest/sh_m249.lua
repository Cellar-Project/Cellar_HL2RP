ITEM.name = "M249"
ITEM.description = "Бельгийский легкий пулемет. Стандартный пулемет для вооруженных сил США."
ITEM.model = "models/weapons/arccw/c_cod4_m249.mdl"
ITEM.class = "arccw_m249"
ITEM.weaponCategory = "primary"
ITEM.classes = {CLASS_EMP, CLASS_EOW}
ITEM.flag = "V"
ITEM.width = 5
ITEM.height = 3
ITEM.iconCam = {
	ang	= Angle(-0.020070368424058, 270.40155029297, 0),
	fov	= 7.2253324508038,
	pos	= Vector(0, 200, -1)
}
ITEM.Attack = 25
ITEM.DistanceSkillMod = {
	[1] = 5,
	[2] = 2,
	[3] = 1,
	[4] = -2
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 6,
		[2] = 1,
		[3] = -1,
		[4] = -4
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 75,
		Shock = {200, 2000},
		Blood = {60, 400},
		Bleed = 60
	}
}


