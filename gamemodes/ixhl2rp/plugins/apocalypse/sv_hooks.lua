local PLUGIN = PLUGIN

function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
	if character:GetData("zombie", false) and character:GetData("zstage", 1) != 3 then
		local timerID = "ixInfection_" .. character:GetID()
		timer.Create(timerID, 600, 3, function()
			if not character then
				timer.Remove(timerID)
			end
			self:AdvanceDisease(character)
		end)
	end
end

hook.Add("prone.CanEnter", "Infection", function(client)
	if client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end)