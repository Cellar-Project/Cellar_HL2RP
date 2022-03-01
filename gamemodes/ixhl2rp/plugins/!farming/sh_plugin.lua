local PLUGIN = PLUGIN

PLUGIN.name = "Farming Plugin"
PLUGIN.author = "Vintage Thief"
PLUGIN.description = ""

ix.config.Add("phasetime", 4, "Time a plant needs to get a point to grow to the next phase.", nil, {
	data = {min = 1, max = 3600},
	category = "farming"
})

ix.config.Add("phaserate", 1, "How much a plant gains growth points on timer tick.", nil, {
	data = {min = 1, max = 100},
	category = "farming"
})

ix.config.Add("phaseamount", 10, "How many points a plant needs to get on the next phase.", nil, {
	data = {min = 10, max = 100},
	category = "farming"
})


ix.config.Add("phases", 4, "How many phases a plant needs to fully grow.", nil, {
	data = {min = 2, max = 8},
	category = "farming"
})

PLUGIN.seedplant = {
	["ix_seeds_potato"] = "breens_water", --test
}

PLUGIN.growmodels = {
	[1] = "models/props/de_train/bush.mdl",
	[2] = "models/props_junk/cardboard_box001a.mdl",
	[3] = "models/props_junk/cardboard_box002a.mdl",
	[4] = "models/props/de_train/bush2.mdl",
}