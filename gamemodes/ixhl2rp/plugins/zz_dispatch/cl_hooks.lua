Schema.scoreboardClasses = {
	["scCityAdm"] = Color(255, 200, 100, 255),
	["scCWU"] = Color(255, 215, 0, 255),
	["scOTA"] = Color(150, 50, 50, 255),
	["scMPF"] = Color(50, 100, 150)
}

local squad_glow_clr = Color(0, 63, 255)

function PLUGIN:OnJoinSquad(squad)
	hook.Add("PreDrawHalos", "SquadGlow", function()
		halo.Add(squad:GetPlayers(), squad_glow_clr, 0.5, 0.5, 0, true, true)
	end)
end

function PLUGIN:OnLeftSquad(squad)
	hook.Remove("PreDrawHalos", "SquadGlow")
end