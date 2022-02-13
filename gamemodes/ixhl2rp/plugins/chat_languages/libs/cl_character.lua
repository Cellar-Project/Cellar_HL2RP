
ix.char.RegisterVar("studiedLanguages", {
	default = {},
	category = "attributes",
	OnDisplay = function(_, container, payload)
		local freeSpace = container:GetTall()
		// label for language panel will be generated after, but it's height will be the same as attributes label
		local childrenTall = container:GetChild(ix.char.vars["attributes"].index - 2):GetTall()

		for _, v in ipairs(container:GetChildren()) do
			if (v != panel) then
				childrenTall = childrenTall + v:GetTall()
			end
		end

		freeSpace = freeSpace - childrenTall

		local topMargin = 4
		local languageSelecter = container:Add("ixLanguageSelecter")
		languageSelecter:Dock(TOP)
		languageSelecter:DockMargin(0, topMargin, 0, 0)
		languageSelecter:SetLanguageList(ix.chatLanguages.list)
		languageSelecter.OnLanguageSelect = function(_, id)
			payload.studiedLanguages = id
		end
		languageSelecter.OnLanguageDeselect = function()
			payload.studiedLanguages = nil
		end

		local targetHeight = languageSelecter:GetChildrenHeight() + topMargin

		if (targetHeight <= freeSpace) then
			languageSelecter:SetTall(targetHeight)
		elseif (targetHeight > freeSpace) then
			languageSelecter:SetTall(freeSpace)
		end

		return languageSelecter
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
	end,
	ShouldDisplay = function()
		return !table.IsEmpty(ix.chatLanguages.list)
	end
})

net.Receive("ixCharacterStudiedLanguagesChanged", function()
	local id = net.ReadUInt(32)
	local key = net.ReadString()
	local value = net.ReadType()
	local character = ix.char.loaded[id]

	if (character) then
		character.vars.studiedLanguages = character.vars.studiedLanguages or {}
		character.vars.studiedLanguages[key] = value
	end
end)
