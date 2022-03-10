
PLUGIN.name = "Chat Languages"
PLUGIN.author = "LegAz"
PLUGIN.description = "Adds library, char var handling languages usage and message text loss on great distances."

ix.util.Include("sh_preperations.lua")

ix.util.Include("libs/sh_chat_languages.lua")
-- this is not the best way to create a char var, but we have no reasons to let it be stolen
ix.util.Include("libs/sv_character.lua")
ix.util.Include("libs/cl_character.lua")
ix.util.Include("meta/sv_player.lua")
ix.util.Include("meta/sh_character.lua")

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sh_commands.lua")

ix.chatLanguages.LoadFromDir(PLUGIN.folder .. "/chat_languages")

function PLUGIN:DoPluginIncludes(path)
	ix.chatLanguages.LoadFromDir(path .. "/chat_languages")
end

function PLUGIN:InitializedChatClasses()
	ix.chatLanguages.AddChatType("ic")
	ix.chatLanguages.AddChatType("w")
	ix.chatLanguages.AddChatType("y")
end
