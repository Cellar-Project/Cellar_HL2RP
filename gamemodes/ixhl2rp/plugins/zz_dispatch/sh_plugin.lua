local PLUGIN = PLUGIN
PLUGIN.name = "Dispatch System"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

dispatch = dispatch or {
	name_format = "CCA:c08.%s",
	unassigned_tag = "UNIT",
	available_tags = {
		"DEFENDER",
		"HERO",
		"JURY",
		"KING",
		"LINE",
		"PATROL",
		"QUICK",
		"ROLLER",
		"STICK",
		"TAP",
		"UNION",
		"VICTOR",
		"XRAY",
		"YELLOW",
		"VICE"
	},
	squads = {}
}

function dispatch.GetReceivers()
	local recvs = {}

	for _, client in ipairs(player.GetAll()) do
		if client:IsCombine() then
			table.insert(recvs, client)
		end
	end

	return recvs
end

ix.util.Include("meta/sh_squads.lua")
