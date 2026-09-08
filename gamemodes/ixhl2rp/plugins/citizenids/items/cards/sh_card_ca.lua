ITEM.name = "CID карта сотрудника ГА"
ITEM.model = Schema.assets.Model("models/vintagethief/cellarproject/cid_card.mdl", "models/props_lab/clipboard.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = ITEM.model == "models/vintagethief/cellarproject/cid_card.mdl" and {
	pos = Vector(0, 0, 12),
	ang = Angle(90, 0, -45),
	fov = 45,
} or false
ITEM.cardType = 3
ITEM.access = {
	["DATAFILE_FULL"] = true,
	["cmbCit*"] = true,
	["cmbCwu*"] = true,
	["cmbMpf*"] = true,
}
