ITEM.name = "Арбалет"
ITEM.description = "Дешево и сердито - главный девиз этого довольно старого, но давно проверенного оружия."
ITEM.model = "models/weapons/arccw/c_bo1_crossbow.mdl"
ITEM.class = "arccw_bo1_crossbow"
ITEM.weaponCategory = "primary"
ITEM.width = 3
ITEM.height = 3
ITEM.rarity = 2
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
		Shock = {666, 3000},
		Blood = {500, 1500},
		Bleed = 90
	}
}