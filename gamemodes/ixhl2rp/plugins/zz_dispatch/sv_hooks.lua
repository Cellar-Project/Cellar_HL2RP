function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
	local faction = ix.faction.Get(character:GetFaction())

	if faction.canSeeWaypoints then
		dispatch.SyncWaypoints(client)
	end

	if dispatch.InDispatchMode(client) and character:GetFaction() != FACTION_DISPATCH then
		dispatch.SetDispatchMode(client, false)
	end

	if character:IsCombine() then
		for k, v in pairs(dispatch.GetSquads()) do
			v:Sync(true, client)
		end

		-- TO DO: Send MPF's ID to AI Dispatch
	end

	if currentChar then
		currentChar:LeaveSquad()
	end
end

function PLUGIN:PlayerDisconnected(client)
	client:LeaveSquad()
end

function PLUGIN:DatafileCombineModifyPoints(client, datafileID, points)

end

function PLUGIN:OnCombineRankChanged(datafileID, oldrank, newrank)
	if oldrank == newrank then return end
	
	local foundPlayer

	for k, v in ipairs(player.GetAll()) do
		if v.ixDatafile == datafileID then
			foundPlayer = v
			break
		end
	end

	if IsValid(foundPlayer) then
		local rank = dispatch.Rank(newrank)

		if rank and rank.class then
			foundPlayer:GetCharacter():SetClass(rank.class())
		end
	end
end

function PLUGIN:CharacterDatafileLoaded(character)
	if character:GetFaction() == FACTION_MPF then
		dispatch.unassigned_squad:AddMember(character)

		local id, genericdata = character:ReturnDatafile(false)
		local rank = genericdata.rank

		if rank > 1 then
			rank = dispatch.Rank(rank)

			if rank and rank.class then
				character:SetClass(rank.class())
			end
		end

		-- TO DO: Send MPF's ID to AI Dispatch
	end
end

function PLUGIN:OnCharacterIDCardChanged(character, newDatafile)
	--if character:GetFaction() == FACTION_MPF then
	--end

	-- TO DO: Send MPF's ID to AI Dispatch
end

local replace = {
	["ic"] = "Radio",
	["whisper"] = "RadioWhisper",
	["yell"] = "RadioYell"
}

function PLUGIN:PrePlayerSay(client, chatType, message, anonymous)
	if client:Team() == FACTION_DISPATCH then
		local rep = replace[chatType]

		if rep then
			ix.command.Run(client, rep, {message})
			return true
		end
	end
end

function PLUGIN:SetupPlayerVisibility(client, vw)
	if IsValid(vw) and vw != client then
		AddOriginToPVS(vw:GetPos())
	end
end

-- DATAFILE_MEDIUM: NO SP
-- DATAFILE_FULL: +3 SP
-- DATAFILE_ELEVATED: INF SP