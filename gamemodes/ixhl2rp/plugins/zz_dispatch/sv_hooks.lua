function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
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

-- DATAFILE_MEDIUM: NO SP
-- DATAFILE_FULL: +3 SP
-- DATAFILE_ELEVATED: INF SP