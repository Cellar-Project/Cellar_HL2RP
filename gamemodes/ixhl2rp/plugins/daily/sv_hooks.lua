local PLUGIN = PLUGIN

ix.util.Include("sh_config.lua")
ix.util.Include("sh_commands.lua")
--ix.util.Include("sv_hooks.lua") ПОСЛЕ ТЕСТА

PLUGIN.name = "Daily Tasks"
PLUGIN.author = "Vintage Thief"
PLUGIN.description = "Provides daily tasks for players."

if CLIENT then
	return
end

PLUGIN.r_category = {
	["r_category"] = math.random(1, 3)
}

function PLUGIN:PlayerInitialSpawn(client)
end