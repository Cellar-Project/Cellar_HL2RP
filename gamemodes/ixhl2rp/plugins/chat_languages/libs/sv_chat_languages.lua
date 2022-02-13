
ix.chatLanguages = ix.chatLanguages or {}
ix.chatLanguages.chatTypesList = ix.chatLanguages.chatTypesList or {}

function ix.chatLanguages.AddChatType(uniqueID)
	if (ix.chat.classes[uniqueID]) then
		ix.chatLanguages.chatTypesList[uniqueID] = true

		return true
	end

	return false
end

function ix.chatLanguages.IsChatTypeValid(uniqueID)
	return tobool(ix.chatLanguages.chatTypesList[uniqueID])
end
