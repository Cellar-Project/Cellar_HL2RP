ITEM.name = "Униформа сотрудника ГО"
ITEM.model = "models/cellar/items/city3/clothing/mpfequipment_c3.mdl"
ITEM.width = 2 -- ширина
ITEM.height = 2 -- высота
ITEM.description = "Стандартная униформа сотрудников Гражданской Обороны Города-3. Сюда входит как стандартный бронежилет, так и защитный воротник. Помимо ботинок, штанов и кителя, тут находятся и разные приспособления по типу ПДА и нескольких вспомогательных ремешков для самых разных предметов."
ITEM.slot = EQUIP_TORSO -- слот ( EQUIP_MASK EQUIP_HEAD EQUIP_LEGS EQUIP_HANDS EQUIP_TORSO )
ITEM.CanBreakDown = false -- можно ли порвать на тряпки
ITEM.thermalIsolation = 3 -- (от 1 до 4)
ITEM.uniform = 0
ITEM.Stats = {
    [HITGROUP_GENERIC] = 0,
    [HITGROUP_HEAD] = 0,
    [HITGROUP_CHEST] = 13,
    [HITGROUP_STOMACH] = 7,
    [4] = 5,
    [5] = 5,
}