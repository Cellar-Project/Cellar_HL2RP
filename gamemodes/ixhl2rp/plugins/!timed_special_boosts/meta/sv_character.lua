
local charMeta = ix.meta.character

function charMeta:AttachDurationToSpecialBoost(boostID, duration)
	local specialBoostsDuration = self:GetSpecialBoostsDuration(boostID)
	specialBoostsDuration[boostID] = duration

	self:SetVar("specialBoostsDuration", specialBoostsDuration)
end

function charMeta:AddSpecialBoostWithDuration(boostID, attribID, boostAmount, duration)
	self:AddSpecialBoost(boostID, attribID, boostAmount)
	self:AttachDurationToSpecialBoost(boostID, duration)
end
