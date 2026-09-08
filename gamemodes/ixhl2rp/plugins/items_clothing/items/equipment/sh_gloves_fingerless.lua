ITEM.name = "Перчатки без пальцев"
ITEM.model = Schema.assets.Model("models/cmbfdr/items/gloves.mdl", "models/props_c17/briefcase001a.mdl")
ITEM.width = 1 -- ширина
ITEM.height = 1 -- высота
ITEM.description = "Неплохие перчатки без пальцев, помогут согреться в городской обстановке."
ITEM.slot = EQUIP_HANDS -- слот ( EQUIP_MASK EQUIP_HEAD EQUIP_LEGS EQUIP_HANDS EQUIP_TORSO )
ITEM.bodyGroups = { -- какие бодигруппы на какие сетаются
    [6] = 2,
}
ITEM.CanBreakDown = true -- можно ли порвать на тряпки
ITEM.thermalIsolation = 3 -- (от 1 до 4)
