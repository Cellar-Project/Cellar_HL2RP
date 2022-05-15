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
    pos = Vector(-1.5029327869415, 206.0539855957, 4.587676525116),
    ang = Angle(0, 270, 0),
    fov = 12.119995321953,
}
ITEM.Attack = 15
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
		[1] = 5,
		[2] = 0,
		[3] = -2,
		[4] = -5
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 50,
		Shock = {110, 2000},
		Blood = {60, 600},
		Bleed = 70
	}
}


