ITEM.name = "СВД-63"
ITEM.description = "Советская полуавтоматическая снайперская винтовка, эстетически схожая с АК-47, созданная для снайперов. Также выпускается китайской оружейной компанией Norinco для китайской армии."
ITEM.model = "models/weapons/arccw/c_bo1_svd.mdl"
ITEM.class = "arccw_bo1_dragunov"
ITEM.weaponCategory = "primary"
ITEM.width = 5
ITEM.rarity = 4
ITEM.height = 2
ITEM.iconCam = {
	ang	= Angle(-0.020070368424058, 270.40155029297, 0),
	fov	= 7.2253324508038,
	pos	= Vector(0, 200, -1)
}
ITEM.Attack = 30
ITEM.DistanceSkillMod = {
	[1] = 1,
	[2] = 3,
	[3] = 5,
	[4] = 4
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 1,
		[2] = 3,
		[3] = 5,
		[4] = 4
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 200,
		Shock = {300, 3000},
		Blood = {200, 1000},
		Bleed = 90
	}
}


