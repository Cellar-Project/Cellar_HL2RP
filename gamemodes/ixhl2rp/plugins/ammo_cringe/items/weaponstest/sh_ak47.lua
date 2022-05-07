ITEM.name = "АК-47"
ITEM.description = "Советский автомат старого образца, но с легкими модификациями от китайских товарищей. Сильная отдача и сильный разборс, но большая огневая мощь покрывает все эти недостатки."
ITEM.model = "models/weapons/w_tdon_mwak_mammal_edition.mdl"
ITEM.class = "arccw_ak47"
ITEM.weaponCategory = "primary"
ITEM.classes = {CLASS_EMP, CLASS_EOW}
ITEM.flag = "V"
ITEM.width = 5
ITEM.height = 2
ITEM.iconCam = {
	ang	= Angle(-0.020070368424058, 270.40155029297, 0),
	fov	= 7.2253324508038,
	pos	= Vector(0, 200, -1)
}
ITEM.Attack = 7
ITEM.DistanceSkillMod = {
	[1] = 5,
	[2] = 0,
	[3] = -2,
	[4] = -5
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 5,
		[2] = 0,
		[3] = -2,
		[4] = -5
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 45,
		Shock = {110, 3000},
		Blood = {60, 666},
		Bleed = 80
	}
}


