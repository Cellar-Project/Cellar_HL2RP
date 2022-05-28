
ITEM.base = "base_textbook"
ITEM.name = "Skills Textbooks Base"
ITEM.description = "iSkillsTextbookDescription"
ITEM.model = Model("models/props_office/book06.mdl")
ITEM.category = "Skills Textbooks"
ITEM.skillID = "str"
ITEM.skillXP = 10
ITEM.volume = 1

function ITEM:GetStudyProgressKey()
	return self.skillID .. self.volume
end

if (CLIENT) then
	function ITEM:GetName()
		local niceName = "skill" .. self.skillID:sub(1, 1) .. self.skillID:sub(2)

		return L("iSkillTextbookName", L(niceName), self.volume)
	end
end

-- base_textbook funcs
function ITEM:PreCanStudy(_, character)
	return character:GetStudyProgress(self:GetStudyProgressKey()) != true
end

function ITEM:CanStudy(client)
	return true
end

function ITEM:GetStudyTimeLeft(_, character)
	return character:GetStudyProgress(self:GetStudyProgressKey())
end

function ITEM:GetMaxStudyTime()
	return ix.config.Get("skillsTextbooksMinReadTime", 3600) * self.volume
end

function ITEM:OnStudyTimeCapped(_, character, studyTime)
	character:SetStudyProgress(self:GetStudyProgressKey(), studyTime)
end

function ITEM:OnTextbookStudied(client, character)
	character:IncreaseSkill(self.skillID, self.skillXP)
	character:SetStudyProgress(self:GetStudyProgressKey(), true)

	local volumeCount = ix.config.Get("skillsTextbooksVolumeCount")
	local skillName = ix.skills.list[self.skillID].name

	client:NotifyLocalized("studiedSkillTextbook", self.volume, volumeCount, skillName, self.skillXP)
	ix.log.Add(client, "studiedSkillTextbook", self.volume, volumeCount, skillName, self.skillXP)
end

function ITEM:OnStudyProgressSave(_, character, timeLeft)
	character:SetStudyProgress(self:GetStudyProgressKey(), timeLeft)
end
