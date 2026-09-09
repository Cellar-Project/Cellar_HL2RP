ITEM.name = "Пулемет Ординала"
ITEM.description = "Тяжелый пулемет производства Вселенского Союза, предназначенный для использования отрядами подавления Солдат Патруля."
ITEM.model = Schema.assets.Model("models/hlvr/weapons/w_suppressor/suppressor_weapon_hlvr.mdl", "models/weapons/w_smg1.mdl")
ITEM.class = "arccw_ordinal"
ITEM.weaponCategory = "primary"
ITEM.rarity = 3
ITEM.width = 5
ITEM.height = 2
ITEM.hasLock = true
ITEM.impulse = true
ITEM.iconCam = ITEM.model == "models/hlvr/weapons/w_suppressor/suppressor_weapon_hlvr.mdl" and {
	pos = Vector(404, 340, 250),
	ang = Angle(24, -139, -19),
	fov = 4,
} or false
ITEM.Attack = 18
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
ITEM.DistanceSkillMod = ITEM.Info.Distance
