ITEM.name = "Фонарик"
ITEM.model = Schema.assets.Model("models/lagmite/lagmite.mdl", "models/maxofs2d/lamp_flashlight.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Обычный фонарик с переключателем."
ITEM.category = "categoryTools"

ITEM:Hook("drop", function(item)
	item.player:Flashlight(false)
end)
