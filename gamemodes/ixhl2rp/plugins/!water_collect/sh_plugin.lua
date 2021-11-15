local PLUGIN = PLUGIN

PLUGIN.name = "Plugin for collecting water"
PLUGIN.author = "Vintage Thief"
PLUGIN.description = ""

ix.config.Add("watertimer", 5, "How ofter water will collect (in seconds)", nil, {
    data = {min = 2, max = 3600},
    category = "watercollector"
})

ix.config.Add("waterlimit", 5, "How much water can be in a container. (ONLY COUNTABLE)", nil, {
    data = {min = 1000, max = 10000},
    category = "watercollector"
})

ix.config.Add("watertick", 2, "How much water you collect on time. (ONLY COUNTABLE)", nil, {
    data = {min = 2, max = 100},
    category = "watercollector"
})