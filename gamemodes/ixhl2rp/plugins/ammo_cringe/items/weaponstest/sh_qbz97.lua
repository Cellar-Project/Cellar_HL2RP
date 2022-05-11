ITEM.name = "QBZ-97"
ITEM.description = "Экспортная версия штурмовой винтовки QBZ-95, принятая на вооружение НОАК. Стреляет патронами 5.56 мм НАТО вместо оригинального китайского 5.8x42 мм DBP87."
ITEM.model = "models/weapons/arccw/c_mw3e_qbz97.mdl"
ITEM.class = "arccw_qbz97"
ITEM.weaponCategory = "primary"
ITEM.classes = {CLASS_EMP, CLASS_EOW}
ITEM.flag = "V"
ITEM.width = 3
ITEM.height = 2
ITEM.rarity = 3
ITEM.iconCam = {
	ang	= Angle(-0.020070368424058, 270.40155029297, 0),
	fov	= 7.2253324508038,
	pos	= Vector(0, 200, -1)
}
ITEM.Attack = 16
ITEM.DistanceSkillMod = {
	[1] = 3,
	[2] = 2,
	[3] = 1,
	[4] = -1
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 3,
		[2] = 2,
		[3] = 1,
		[4] = -2
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 32,
		Shock = {88, 1000},
		Blood = {40, 350},
		Bleed = 60
	}
}


