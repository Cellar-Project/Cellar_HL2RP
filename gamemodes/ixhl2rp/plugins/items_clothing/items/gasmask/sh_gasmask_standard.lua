ITEM.name = "Противогаз ГП-7"
ITEM.model = Model("models/cellar/items/city3/clothing/gp5.mdl")
ITEM.width = 1 -- ширина
ITEM.height = 1 -- высота
ITEM.description = "Старый противогаз советского образца. Судя по стертой маркировке где-то внутри самого противогаза, он успел побывать на складах не одной армии. В нем бывает довольно холодно временами."
ITEM.slot = EQUIP_MASK -- слот ( EQUIP_MASK EQUIP_HEAD EQUIP_LEGS EQUIP_HANDS EQUIP_TORSO )
ITEM.bodyGroups = { -- какие бодигруппы на какие сетаются
	[2] = 3
}
ITEM.rarity = 1
ITEM.CanBreakDown = false -- можно ли порвать на тряпки
ITEM.thermalIsolation = 1 -- (от 1 до 4)
ITEM.Filters = {
	["filter_epic"] = false,
	["filter_good"] = true,
	["filter_medium"] = true,
	["filter_standard"] = true
}
ITEM.Stats = {
	[HITGROUP_GENERIC] = 0,
	[HITGROUP_HEAD] = 1,
	[HITGROUP_CHEST] = 0,
	[HITGROUP_STOMACH] = 0,
	[4] = 0,
	[5] = 0,
}

function ITEM:CanEquip(client, slot)
	return !tobool(client:GetCharacter():GetEquipment():GetItemAtSlot("head"))
end