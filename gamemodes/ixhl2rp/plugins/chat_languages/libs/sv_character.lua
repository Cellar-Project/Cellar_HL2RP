
util.AddNetworkString("ixCharacterStudiedLanguagesChanged")
util.AddNetworkString("ixCharacterChangeUsedLanguage")

ix.char.RegisterVar("studiedLanguages", {
	field = "studied_languages",
	fieldType = ix.type.text,
	default = {},
	OnSet = function(character, key, value, bNoReplication, receiver)
		if (ix.chatLanguages.Get(key) and (!value or isbool(value))) then
			local studiedLanguages = character:GetStudiedLanguages()
			local client = character:GetPlayer()

			studiedLanguages[key] = value

			if (!bNoReplication and IsValid(client)) then
				net.Start("ixCharacterStudiedLanguagesChanged")
					net.WriteUInt(character:GetID(), 32)
					net.WriteString(key)
					net.WriteType(value)
				net.Send(receiver or client)
			end

			character.vars.studiedLanguages = studiedLanguages

			if (!value and character:GetUsedLanguage() == key) then
				character:SetUsedLanguage("")
			end
		end
	end,
	OnValidate = function(_, value)
		if (value != nil) then
			if (isstring(value)) then
				if (!ix.chatLanguages.Get(value)) then
					return false, "unknownError"
				end

				return {[value] = true}
			else
				return false, "unknownError"
			end
		end
	end,
	OnGet = function(character, key, default)
		local studiedLanguages = character.vars.studiedLanguages or {}

		if (key) then
			if (!studiedLanguages) then
				return default
			end

			local value = studiedLanguages[key]

			return value == nil and default or value
		else
			return default or studiedLanguages
		end
	end
})

do
	local charMeta = ix.meta.character

	function charMeta:ResetLanguageLeftStudyTime(languageID, genericDataKey, volumeCount)
		genericDataKey = genericDataKey or ix.chatLanguages.GetStudyTimeLeftGenericDataKey(languageID)
		volumeCount = volumeCount or ix.config.Get("languageTextbooksVolumeCount", 3)

		for i = 1, volumeCount do
			self:SetData(genericDataKey .. i, nil)
		end
	end
end

net.Receive("ixCharacterChangeUsedLanguage", function(_, client)
	local curTime = CurTime()

	if ((client.ixNextUsedLanguageChange or 0) <= curTime) then
		local character = client:GetCharacter()

		if (character) then
			local id = net.ReadString()
			local bNoID = id == ""

			if (
				(bNoID or ix.chatLanguages.Get(id)) and
				(bNoID or character:CanSpeakLanguage(id)) and
				id != character:GetUsedLanguage()
			) then
				character:SetUsedLanguage(id)
			end
		end

		client.ixNextUsedLanguageChange = curTime + 0.2
	end
end)
