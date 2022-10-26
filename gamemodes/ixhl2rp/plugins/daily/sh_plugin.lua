local PLUGIN = PLUGIN

PLUGIN.name = "Daily Tasks"
PLUGIN.author = "Vintage Thief"
PLUGIN.description = "Provides daily tasks for players."

ix.util.Include("sh_config.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("libs/sv_character.lua") -- daily tasks vars :(

if CLIENT then
	return
end

PLUGIN.r_category = {
	["r_category"] = math.random(0, 2)
}
if (SERVER) then
	function PLUGIN:PlayerLoadedCharacter(_, character)
		
	end
end