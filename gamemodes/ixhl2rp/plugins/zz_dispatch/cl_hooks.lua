Schema.scoreboardClasses = {
	["scCityAdm"] = Color(255, 200, 100, 255),
	["scCWU"] = Color(255, 215, 0, 255),
	["scOTA"] = Color(150, 50, 50, 255),
	["scMPF"] = Color(50, 100, 150)
}

local squad_glow_clr = Color(0, 63, 255)

function PLUGIN:CharacterLoaded(character)
	local faction = ix.faction.Get(character:GetFaction())

	if faction.canSeeWaypoints then
		hook.Add("HUDPaint", "dispatch.waypoints", dispatch.DrawWaypoints)
		hook.Add("CreateMove", "dispatch.radialmenu", dispatch.ShowQuickPingMenu)
	else
		hook.Remove("HUDPaint", "dispatch.waypoints")
		hook.Remove("CreateMove", "dispatch.radialmenu")
	end

	if character:IsCombine() and character:GetFaction() != FACTION_DISPATCH then
		hook.Add("PlayerButtonDown", "dispatch.quick", function(_, btn) if btn == KEY_LALT then hook.Run("patrolmenu.open") end end)
		hook.Add("PlayerButtonUp", "dispatch.quick", function(_, btn) if btn == KEY_LALT then hook.Run("patrolmenu.close") end end)
	else
		hook.Remove("PlayerButtonDown", "dispatch.quick")
		hook.Remove("PlayerButtonUp", "dispatch.quick")
	end
end

function PLUGIN:OnJoinSquad(squad)
	hook.Add("PreDrawHalos", "SquadGlow", function()
		halo.Add(squad:GetPlayers(), squad_glow_clr, 0.5, 0.5, 0, true, true)
	end)
end

function PLUGIN:OnLeftSquad(squad)
	hook.Remove("PreDrawHalos", "SquadGlow")
end

-- wtf is the km
function PLUGIN:OnSquadChangedLeader(id, squad, character)
	if IsValid(ix.gui.squads) then 
		ix.gui.squads:OnSquadChangedLeader(id, squad, character)
	end

	if IsValid(ix.gui.dispatch) then 
		ix.gui.dispatch:OnSquadChangedLeader(id, squad, character)
	end
end

function PLUGIN:OnSquadMemberLeft(id, squad, character)
	if IsValid(ix.gui.squads) then
		ix.gui.squads:OnSquadMemberLeft(id, squad, character)
	end

	if IsValid(ix.gui.dispatch) then
		ix.gui.dispatch:OnSquadMemberLeft(id, squad, character)
	end
end

function PLUGIN:OnSquadMemberJoin(id, squad, character)
	if IsValid(ix.gui.squads) then
		ix.gui.squads:OnSquadMemberJoin(id, squad, character)
	end

	if IsValid(ix.gui.dispatch) then
		ix.gui.dispatch:OnSquadMemberJoin(id, squad, character)
	end
end

function PLUGIN:OnSquadDestroy(id, squad)
	if IsValid(ix.gui.squads) then
		ix.gui.squads:OnSquadDestroy(id, squad)
	end

	if IsValid(ix.gui.dispatch) then
		ix.gui.dispatch:OnSquadDestroy(id, squad)
	end
end

function PLUGIN:OnSquadSync(id, squad, full)
	if IsValid(ix.gui.squads) then
		ix.gui.squads:OnSquadSync(id, squad, full)
	end

	if IsValid(ix.gui.dispatch) then
		ix.gui.dispatch:OnSquadSync(id, squad, full)
	end
end