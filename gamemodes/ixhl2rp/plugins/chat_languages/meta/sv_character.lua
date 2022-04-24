
local charMeta = ix.meta.character

function charMeta:SetLanguageStudyProgress(languageID, volumeNumber, progress)
	if (ix.chatLanguages.Get(languageID)) then
		local studyProgress = self:GetLanguagesStudyProgress()

		studyProgress[languageID] = studyProgress[languageID] or {}
		studyProgress[languageID][volumeNumber] = progress

		self:SetLanguagesStudyProgress(studyProgress)
	end
end

function charMeta:ClearLanguageStudyProgress(languageID)
	if (ix.chatLanguages.Get(languageID)) then
		local studyProgress = self:GetLanguagesStudyProgress()
		studyProgress[languageID] = nil

		if (studyProgress != self:GetLanguagesStudyProgress()) then
			self:SetLanguagesStudyProgress(studyProgress)
		end
	end
end
