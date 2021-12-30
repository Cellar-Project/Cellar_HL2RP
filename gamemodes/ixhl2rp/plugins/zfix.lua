ix.command.Add("ZRemove", {
	description = "Remove disease.",
	superAdminOnly = true,
	arguments = ix.type.character,
	OnRun = function(self, client, character)
		character:SetData("zombie", nil)
		character:SetData("zstage", nil)
		timer.Remove("ixInfection_" .. character:GetID())
		timer.Remove("infection_" .. character:GetID())
	end
})