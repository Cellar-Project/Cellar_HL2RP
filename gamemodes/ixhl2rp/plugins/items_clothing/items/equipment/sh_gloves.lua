ITEM.name = "Перчатки с пальцами"
ITEM.model = Schema.assets.Model("models/cmbfdr/items/gloves.mdl", "models/props_c17/briefcase001a.mdl")
ITEM.width = 1 -- ширина
ITEM.height = 1 -- высота
ITEM.description = "Большие резиновые перчатки, которые плотно прилегают к пальцам. Хорошо согревают даже в самую холодную погоду в этом дренном городе."
ITEM.slot = EQUIP_HANDS -- слот ( EQUIP_MASK EQUIP_HEAD EQUIP_LEGS EQUIP_HANDS EQUIP_TORSO )
ITEM.bodyGroups = { -- какие бодигруппы на какие сетаются
    [6] = 1,
}
ITEM.CanBreakDown = false -- можно ли порвать на тряпки
ITEM.thermalIsolation = 4 -- (от 1 до 4)
