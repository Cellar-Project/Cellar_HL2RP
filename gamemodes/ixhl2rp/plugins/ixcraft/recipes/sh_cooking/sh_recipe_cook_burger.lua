RECIPE.name = "Бургер"
RECIPE.category = "Кулинария"
RECIPE.requirements = {
	["dough"] = 1,
	["fried_meat"] = 1,
	["vegatables"] = 2,
	["cheese"] = 1,
	["ketchup"] = 1,
}
RECIPE.results = {
	["burger"] = {
		min = 2,
		max = 3
	}
}
RECIPE.station = "station_cook" or "station_cook_field"
RECIPE.skill = {"cooking", 1}
RECIPE.description = nil
RECIPE.model = nil