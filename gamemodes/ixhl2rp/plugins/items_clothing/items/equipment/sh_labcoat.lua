ITEM.name = "Лабораторный халат"
ITEM.model = Schema.assets.Model("models/cellar/items/city3/clothing/halat.mdl", "models/props_c17/suitcase_passenger_physics.mdl")
ITEM.width = 2 -- ширина
ITEM.height = 2 -- высота
ITEM.description = "Самый обычный белый лабораторный халат, одинаково подойдет к ношению для представителей любого пола."
ITEM.slot = EQUIP_TORSO -- слот ( EQUIP_MASK EQUIP_HEAD EQUIP_LEGS EQUIP_HANDS EQUIP_TORSO )
ITEM.bodyGroups = { -- какие бодигруппы на какие сетаются
    [5] = 8
}
ITEM.CanBreakDown = true -- можно ли порвать на тряпки
ITEM.thermalIsolation = 1 -- (от 1 до 4)
