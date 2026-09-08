ITEM.name = "Медицинская маска"
ITEM.model = Schema.assets.Model("models/cellar/items/surgerymask.mdl", "models/props_c17/briefcase001a.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "С помощью этой маски можно прикрыть свой рот и нос от попадания разного рода пыли и грязи, но самый главный смысл этой маски - не дать распространяться болезни. Ученые Альянса доказали, что ношение маски может помочь с борьбе с распространением вирусных заболеваний, но у сотрудников Гражданской Обороны по этому поводу другое мнение. Просто так такое нельзя носить!"
ITEM.slot = EQUIP_MASK
ITEM.bodyGroups = {
	[2] = 1,
}
ITEM.iconCam = ITEM.model == "models/cellar/items/surgerymask.mdl" and {
	pos = Vector(0, 200, -0.49698188900948),
	ang = Angle(0, 270, 0),
	fov = 1.8941635831843,
} or false
ITEM.CanBreakDown = false

function ITEM:CanEquip(client, slot)
	local equipment = client:GetCharacter():GetEquipment()
	return !(equipment:HasItem("facial_bandage", {equip = true}))
end
