local squad_glow_clr = Color(0, 63, 255)

function PLUGIN:OnJoinSquad(squad)
	hook.Add("PreDrawHalos", "SquadGlow", function()
		halo.Add(squad:GetPlayers(), squad_glow_clr, 0.5, 0.5, 0, true, true)
	end)
end

function PLUGIN:OnLeftSquad(squad)
	hook.Remove("PreDrawHalos", "SquadGlow")
end