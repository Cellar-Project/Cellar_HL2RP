do
	local color_text = Color(0, 0, 0, 255)
	local color_inactive = Color(0, 226, 255, 50)
	local color_hover_bg = Color(0, 226, 255, 255)

	local PANEL = {}
	function PANEL:Init()
		self:SetFont("dispatch.tab.bold")
		self:SetTextColor(color_hover_bg)
	end

	function PANEL:OnCursorEntered()
		self.isHovered = true
		self:SetTextColor(color_text)
	end

	function PANEL:OnCursorExited()
		self.isHovered = false
		self:SetTextColor(color_hover_bg)
	end

	function PANEL:Paint(w, h)
		surface.SetDrawColor(color_hover_bg)
		surface.DrawRect(0, h - 2, w, 2)

		surface.SetDrawColor(color_inactive)
		surface.DrawRect(0, 0, w, h)

		if self.isHovered then
			render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD, BLEND_DST_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_ADD)

			surface.SetDrawColor(color_hover_bg)
			surface.DrawRect(0, 0, w, h)

			render.OverrideBlend(false)
		end
	end

	vgui.Register("squad.top.button", PANEL, "DButton")
end

do
	local function scale(px)
		return math.ceil(math.max(480, ScrH()) * (px / 1080))
	end

	local PANEL = {}
	local background = Material("cellar/ui/dispatch/bg.png", "smooth")
	local border_size = scale(64)

	function PANEL:Init()
		if IsValid(ix.gui.squads) then
			ix.gui.squads:Remove()
		end

		ix.gui.squads = self

		local scrW, scrH = ScrW(), ScrH()

		self:SetSize(scrW, scrH)

		do
			local frame = self:Add("dispatch.window")
			frame:SetWide(scrH * 0.65)
			frame:SetPos(border_size, border_size)
			frame:SetWindowName("ПАТРУЛЬНЫЕ ГРУППЫ")

			local w, h = frame.container:GetWide()

			self.create_squad = frame:Insert("squad.top.button")
			self.create_squad:Dock(TOP)
			self.create_squad:SetText("СОЗДАТЬ ПАТРУЛЬНУЮ ГРУППУ")
			self.create_squad:SetTall(32)
			self.create_squad.DoClick = function()
				ix.command.Send("SquadCreate")
			end

			local container = frame:Insert("EditablePanel")
			container:Dock(TOP)
			container:SetTall((scrH - border_size * 2) / 2)
			container:InvalidateParent(true)

			local x2, y2, w2, h2 = container:GetBounds()

			self.patrols = container:Add("DScrollPanel")
			self.patrols:SetSize(w, h2)

			frame:UpdateContainer()
		end

		self:SetMouseInputEnabled(true)
		self:SetKeyboardInputEnabled(true)
		self:RequestFocus()

		self:BuildSquads()
	end

	function PANEL:BuildSquads()
		self.squads = {}

		for tag = 1, #dispatch.available_tags do
			local a = self.patrols:Add("squadCategoryBtn")
			a:DockMargin(0, 1, 16, 0)
			a:Dock(TOP)

			if !dispatch.squads[tag] then
				a:SetupSquad(tag)
			else
				a:SetupSquadFull(dispatch.squads[tag])
			end

			self.squads[tag] = a
		end
	end

	function PANEL:OnSquadSync(id, squad, full)
		self.squads[id]:SetupSquadFull(squad)
		self.squads[id]:SetVisible(squad.member_counter > 0)
		self.squads[id]:UpdateSquadInfo()
	end
	function PANEL:OnSquadDestroy(id, squad)
		for char, _ in pairs(self.squads[id].members) do
			self.squads[id]:RemoveMember(char)
		end

		self.squads[id]:UpdateSquadInfo()
		self.squads[id]:SetVisible(false)
	end
	function PANEL:OnSquadMemberJoin(id, squad, character)
		self.squads[id]:AddMember(character)

		if squad.member_counter > 0 then
			self.squads[id]:SetVisible(true)
		end

		self.squads[id]:UpdateSquadInfo()
	end
	function PANEL:OnSquadMemberLeft(id, squad, character)
		self.squads[id]:RemoveMember(character)

		if squad.member_counter <= 0 then
			self.squads[id]:SetVisible(false)
		end

		self.squads[id]:UpdateSquadInfo()
	end
	function PANEL:OnSquadChangedLeader(id, squad, character)
		self.squads[id]:SetLeader(character)
	end

	function PANEL:Paint(w, h) end

	vgui.Register("squads.main", PANEL, "EditablePanel")
end

/*
hook.Add("PlayerButtonDown", "dispatch.quick", function(ply, button)
	if button == KEY_LALT then
		hook.Run("OnQuickMenuOpen")
	end
end)

hook.Add("PlayerButtonUp", "dispatch.quick", function(ply, button)
	if button == KEY_LALT then
		hook.Run("OnQuickMenuClose")
	end
end)

hook.Add("OnQuickMenuOpen", "dispatch.quick", function()
	QUICKMENU_OPEN = true
	gui.EnableScreenClicker(true)

	vgui.Create("squads.main")
end)

hook.Add("OnQuickMenuClose", "dispatch.quick", function()
	QUICKMENU_OPEN = false
	gui.EnableScreenClicker(false)

	ix.gui.squads:Remove()
end)
*/