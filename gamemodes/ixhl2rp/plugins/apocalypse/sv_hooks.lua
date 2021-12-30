local PLUGIN = PLUGIN


function PLUGIN:PlayerLoadedCharacter(client, character)
	if character:GetData("zombie", false) then
		local timerID = "ixInfection_" .. character:GetID()
		timer.Create(timerID, 600, 3, function()
			if not character then
				timer.Remove(timerID)
			end
			self:AdvanceDisease(character)
		end)
	end
end

-- I don't know WHY THE FUCK this shit only works
-- when I put it in sv, sh and cl (it makes no sense!!!). I tried EVERYTHING. Help me.
function PLUGIN:CanPlayerEquipItem(client, item, slot)
	if IsValid(client) and client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end

function PLUGIN:CanPlayerInteractItem(client, action)
	if IsValid(client) and client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end

function PLUGIN:CanPlayerInteractEntity(client, entity)
	if IsValid(client) and client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end