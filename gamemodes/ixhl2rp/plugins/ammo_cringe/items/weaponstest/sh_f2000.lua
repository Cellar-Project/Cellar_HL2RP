ITEM.name = "FN F2000"
ITEM.description = "Громоздкая бельгийская штурмовая винтовка, стреляющая патронами 5,56 мм НАТО, использует конфигурацию булл-пап для сохранения компактных размеров."
ITEM.model = "models/weapons/arccw/w_mw2e_f2000.mdl"
ITEM.class = "arccw_f2000"
ITEM.weaponCategory = "primary"
ITEM.classes = {CLASS_EMP, CLASS_EOW}
ITEM.flag = "V"
ITEM.width = 3
ITEM.rarity = 3
ITEM.height = 2
ITEM.iconCam = {
	ang	= Angle(-0.020070368424058, 270.40155029297, 0),
	fov	= 7.2253324508038,
	pos	= Vector(0, 200, -1)
}
ITEM.Attack = 14
ITEM.DistanceSkillMod = {
	[1] = 5,
	[2] = 4,
	[3] = 1,
	[4] = -3
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 5,
		[2] = 4,
		[3] = 1,
		[4] = -3
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 30,
		Shock = {80, 800},
		Blood = {35, 350},
		Bleed = 60
	}
}


