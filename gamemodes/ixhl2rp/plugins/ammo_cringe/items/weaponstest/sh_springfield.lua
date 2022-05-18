ITEM.name = "Военная снайперская винтовка"
ITEM.description = "Старая военная снайперская винтовка."
ITEM.model = "models/weapons/c_militarysniper.mdl"
ITEM.class = "arccw_militarysniper"
ITEM.weaponCategory = "primary"
ITEM.width = 5
ITEM.height = 2
ITEM.rarity = 4
ITEM.iconCam = {
	ang	= Angle(-0.020070368424058, 270.40155029297, 0),
	fov	= 7.2253324508038,
	pos	= Vector(0, 200, -1)
}
ITEM.Attack = 16
ITEM.DistanceSkillMod = {
	[1] = 1,
	[2] = 4,
	[3] = 5,
	[4] = 2
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 1,
		[2] = 4,
		[3] = 5,
		[4] = 2
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 50,
		Shock = {500, 3000},
		Blood = {400, 800},
		Bleed = 90
	}
}


