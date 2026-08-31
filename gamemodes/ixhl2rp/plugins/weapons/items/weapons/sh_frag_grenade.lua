ITEM.name = "MK3A2"
ITEM.description = "Осколочная граната, оснащенная предупредительным сигналом, повсеместно используется силами Надзора и представляет из себя модификацию земного предшественника — MK3A1."
ITEM.model = "models/items/grenadeammo.mdl"
ITEM.class = "weapon_frag"
ITEM.weaponCategory = "grenade"
ITEM.isGrenade = true
ITEM.rarity = 2
ITEM.width = 1
ITEM.height = 1
ITEM.Info = {
	Type = nil,
	Skill = "throwing",
	Distance = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0
	},
	Dmg = {
		Attack = 100,
		AP = 100,
		Limb = 22,
		Shock = {937, 3750},
		Blood = {375, 1500},
		Bleed = 95
	}
}
ITEM.DistanceSkillMod = ITEM.Info.Distance
