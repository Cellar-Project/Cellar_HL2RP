local PLUGIN = PLUGIN

PLUGIN.name = "Combie Visors"
PLUGIN.author = "maxxoft"
PLUGIN.description = "Combine mask-based visors."

local CHAR = ix.meta.character
local PLAYER = FindMetaTable("Player")

function CHAR:GetVisorLevel()
	local inv = self:GetEquipment()
	return inv:GetItemAtSlot(EQUIP_MASK) and inv:GetItemAtSlot(EQUIP_MASK).visorLevel or 0
end

function PLAYER:CanUseNightVision()
	return self:GetCharacter():GetVisorLevel() == 2
end

function CHAR:HasVisor()
	return self:GetVisorLevel() != 0
end
