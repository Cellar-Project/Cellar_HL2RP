local function scale(px)
	return math.ceil(math.max(480, ScrH()) * (px / 1080))
end

surface.CreateFont("dispatch.stat.label", {
	font = "Blender Pro Book",
	size = 18,
	weight = 400,
	antialias = true,
	extended = true
})

surface.CreateFont("dispatch.stat.value", {
	font = "Blender Pro Book",
	size = 21,
	weight = 500,
	antialias = true,
	extended = true
})

surface.CreateFont("dispatch.window", {
	font = "Blender Pro Book",
	size = 14,
	weight = 800,
	antialias = true,
	extended = true
})

surface.CreateFont("dispatch.tab", {
	font = "Blender Pro Book",
	size = 18,
	weight = 500,
	antialias = true,
	extended = true
})
surface.CreateFont("dispatch.tabfunc", {
	font = "Blender Pro Medium",
	size = 18,
	weight = 600,
	antialias = true,
	extended = true
})
surface.CreateFont("dispatch.camera.button", {
	font = "Blender Pro Bold",
	size = 16,
	weight = 800,
	antialias = true,
	extended = true
})

do
	local PANEL = {}
	function PANEL:Init()
		self.label = self:Add("DLabel")
		self.label:SetFont("dispatch.stat.label")
		self.label:Dock(FILL)
		self.label:SetContentAlignment(1)

		self.value = self:Add("DLabel")
		self.value:SetFont("dispatch.stat.value")
		self.value:Dock(RIGHT)
		self.value:SetContentAlignment(3)

		self:DockPadding(0, 0, 0, 2)
		self:DockMargin(0, 0, 0, 13)
	end

	function PANEL:SetLabel(label)
		self.label:SetText(label)
		self.label:SizeToContents()
	end

	function PANEL:SetLabelColor(clr)
		self.label:SetTextColor(clr)
	end
	
	function PANEL:SetValue(value)
		self.value:SetText(value)
		self.value:SizeToContents()
	end
	
	local clr = Color(255, 255, 255, 255 * 0.08)
	function PANEL:Paint(w, h)
		surface.SetDrawColor(clr)
		surface.DrawLine(0, h - 1, w, h - 1)
	end

	vgui.Register("dispatch.window.stat", PANEL, "EditablePanel")

	local button_h = scale(16)
	local colors = {
		[1] = Color(0, 56, 64, 255 * 0.4),
		[2] = Color(0, 255, 255, 255 * 0.1),
		[3] = Color(0, 226, 255, 255)
	}

	PANEL = {}

	function PANEL:Init()
		self.oldSetWide = self.oldSetWide or self.SetWide
		self.SetWide = function(this, n)
			self.container:SetWide(n - 13 * 2)
			this:oldSetWide(n)
		end

		self.state = false

		self.container = self:Add("Panel")
		self.container:Dock(FILL)
		self.container:DockPadding(13, 13, 13, 13)
		self.container.Paint = function(_, w, h)
			surface.SetDrawColor(colors[2])
			surface.DrawOutlinedRect(0, 0, w, h)

			surface.SetDrawColor(colors[1])
			surface.DrawRect(0, 0, w, h)
		end

		self.button_poly = {
			{x = 0, y = 0},
			{x = 64, y = 0},
			{x = 64 - 8, y = 8},
			{x = 8, y = 8}
		}

		self.button = self:Add("DButton")
		self.button:SetFont("dispatch.window")
		self.button:SetTextColor(color_black)
		self.button:DockMargin(0, 2, 0, 0)
		self.button:Dock(BOTTOM)
		self.button:SetTall(button_h)
		self.button.Paint = function(_, w, h)
			surface.SetDrawColor(colors[3])
			surface.DrawRect(0, 0, w, 2)

			draw.NoTexture()
			surface.DrawPoly(self.button_poly)
		end
		self.button.DoClick = function()
			self:Open()
		end

		self:SetTall(button_h + 2)

		
	end

	function PANEL:SetWindowName(value)
		surface.SetFont("dispatch.window")
		local win_w, win_h = self:GetWide()
		local w, h = surface.GetTextSize(value)

		self.button:SetText(value)
		self.button_poly = {
			{x = win_w / 2 - w / 2 - button_h - 2, y = 0},
			{x = win_w / 2 + w / 2 + button_h + 2, y = 0},
			{x = win_w / 2 + w / 2 + 2, y = button_h},
			{x = win_w / 2 - w / 2 - 2, y = button_h}
		}
	end
	
	function PANEL:Insert(class)
		local obj = self.container:Add(class)

		return obj
	end

	function PANEL:UpdateContainer()
		self.container:InvalidateLayout(true)
		self.container:SizeToChildren(false, true)
	end


	function PANEL:Open()
		if self.animating then
			return
		end
		
		local w, h = self.container:ChildrenSize()

		self.animating = true
		self:SizeTo(-1, self.state and (button_h + 2) or (h + button_h + 2), 0.25, 0, -1, function()
			self.animating = false
		end)

		self.state = !self.state
	end
	
	vgui.Register("dispatch.window", PANEL, "EditablePanel")
end

do
	local color_hover = Color(0, 226, 255, 255)
	local color_inactive = Color(0, 226, 255, 128)
	local color_selected = Color(0, 226, 255, 255)
	local color_hover_bg = Color(0, 255, 255, 4)
	local color_active_bg = Color(0, 255, 255, 16)

	local PANEL = {}
	function PANEL:Init()
		self:SetFont("dispatch.tab")
		self:SetTextColor(color_inactive)

		self.active = false
	end

	function PANEL:OnCursorEntered()
		self.isHovered = true
		self:SetTextColor(self.active and color_selected or color_hover)
	end

	function PANEL:OnCursorExited()
		self.isHovered = false
		self:SetTextColor(self.active and color_selected or color_inactive)
	end
	
	function PANEL:DoClick()
		for k, v in ipairs(self:GetParent().buttons) do if v == self then continue end v.active = false end
		
		self.active = !self.active

		self:SetTextColor(self.active and color_selected or color_inactive)

		self:DoSwitch()
	end

	function PANEL:Paint(w, h)
		surface.SetDrawColor(self.active and color_selected or color_inactive)
		surface.DrawRect(0, h - 2, w, 2)

		if self.isHovered and !self.active then
			surface.SetDrawColor(color_hover_bg)
			surface.DrawRect(0, 0, w, h)
		elseif self.active then
			surface.SetDrawColor(color_active_bg)
			surface.DrawRect(0, 0, w, h)
		end
	end

	function PANEL:DoSwitch()
	end
	
	vgui.Register("dispatch.window.tab", PANEL, "DButton")
end

do
	local color_inactive = Color(0, 0, 0, 255)
	local color_inactive_bg = Color(0, 226, 255, 200)
	local color_hover_bg = Color(0, 255, 255, 255)

	local PANEL = {}
	function PANEL:Init()
		self:SetFont("dispatch.tabfunc")
		self:SetTextColor(color_inactive)
	end

	function PANEL:OnCursorEntered()
		self.isHovered = true
	end

	function PANEL:OnCursorExited()
		self.isHovered = false
	end
	
	function PANEL:Paint(w, h)
		surface.SetDrawColor(self.isHovered and color_hover_bg or color_inactive_bg)
		surface.DrawRect(0, 0, w, h)
	end
	
	vgui.Register("dispatch.window.tabfunc", PANEL, "DButton")
end

do
	local color_bg = Color(0, 255, 255, 15)

	local PANEL = {}
	function PANEL:PaintBG(w, h)
		surface.SetDrawColor(color_bg)
		surface.DrawRect(0, 0, w, h)

	end
	
	function PANEL:Paint(w, h)
		if self.hovered then
			render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_DST_COLOR, BLENDFUNC_ADD, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_ADD )

			surface.SetDrawColor(Color(0, 255, 255, 255 * 0.5))
			surface.DrawRect(0, 0, w, h)
			render.OverrideBlend(false)

		end
	end
	function PANEL:Init()
		self:SetText("")
		self:SetTall(25)

		self.hovered = false

		self.code = self:Add("Panel")
		self.code:Dock(RIGHT)
		self.code:DockMargin(1, 0, 0, 0)
		self.code:SetMouseInputEnabled(false)
		
		self.code_text = self.code:Add("DLabel")
		self.code_text:Dock(FILL)
		self.code_text:SetContentAlignment(5)

		self.class = self:Add("Panel")
		self.class:Dock(RIGHT)
		self.class:DockMargin(1, 0, 0, 0)
		self.class:SetMouseInputEnabled(false)

		self.class_text = self.class:Add("DLabel")
		self.class_text:Dock(FILL)
		self.class_text:SetContentAlignment(5)

		self.header = self:Add("Panel")
		self.header:Dock(FILL)
		self.header:SetMouseInputEnabled(false)

		self.indicator = self.header:Add("Panel")
		self.indicator:Dock(LEFT)
		self.indicator:DockMargin(0, 0, 5, 0)
		self.indicator:SetWide(self:GetTall())

		self.text = self.header:Add("DLabel")
		self.text:Dock(FILL)
		self.text:SetContentAlignment(4)

		self.text:SetFont("dispatch.camera.button")
		self.code_text:SetFont("dispatch.camera.button")
		self.class_text:SetFont("dispatch.camera.button")

		self.code.parent = self
		self.class.parent = self
		self.header.parent = self

		self.code.Paint = self.PaintBG
		self.class.Paint = self.PaintBG
		self.header.Paint = self.PaintBG
	end

	function PANEL:OnCursorEntered()
		self.hovered = true
	end

	function PANEL:OnCursorExited()
		self.hovered = false
	end

	function PANEL:SetEntity(entity)
		self.DoClick = function()
			ix.gui.dispatch:RequestCamera(entity)
		end

		self.class_text:SetText(entity:GetCameraData():Type())
	end
	
	function PANEL:PerformLayout(w, h)

		self.class:SetWide(w * 0.15)
		self.code:SetWide(w * 0.15)

		self.header:SetWide(w - self.class:GetWide() - self.code:GetWide())
	end

	vgui.Register("dispatch.camera.button", PANEL, "DButton")
end

do
	local PANEL = {}
	local background = Material("cellar/ui/dispatch/bg.png", "smooth")
	local border_size = scale(64)

	function PANEL:Init()
		if IsValid(ix.gui.dispatch) then
			ix.gui.dispatch:Remove()
		end

		ix.gui.dispatch = self

		local scrW, scrH = ScrW(), ScrH()

		self:SetSize(scrW, scrH)

		local stability_w, stability_h = scale(385), scale(52)
		local stability = self:Add("DButton")
		stability:SetSize(stability_w, stability_h)
		stability:SetPos(scrW - stability_w - border_size, border_size / 2 - stability_h / 2)
		stability.DoClick = function()
			self:SwitchStability()
		end
		--stability.Paint = function(_, w, h)
		--	surface.SetDrawColor(color_white)
		--	surface.DrawRect(0, 0, w, h)
		--end

		do
			self.manpower = self:Add("dispatch.window")
			self.manpower:SetWide(stability_w)
			self.manpower:SetPos(scrW - stability_w - border_size, border_size)
			self.manpower:SetWindowName("MANPOWER")
			self.manpower.stats = {}

			for i = 1, 3 do
				local stat = self.manpower:Insert("dispatch.window.stat")
				stat:Dock(TOP)
				stat:SetLabel("")
				stat:SetValue("")

				self.manpower.stats[i] = stat

				self.manpower:UpdateContainer()
			end
		end

		self.manpower.stats[1]:SetLabel("TEAMS")
		self.manpower.stats[1]:SetValue(string.format("%i/15", #dispatch.squads))

		do
			local frame = self:Add("dispatch.window")
			frame:SetWide(scrH * 0.65)
			frame:SetPos(border_size, border_size)
			frame:SetWindowName("ASSETS")

			local test = frame:Insert("Panel")
			test:Dock(TOP)
			test:SetTall(32)
			test.buttons = {}

			local w, h = frame.container:GetWide()

			local tab1 = test:Add("dispatch.window.tab")
			tab1:Dock(LEFT)
			tab1:SetText("SQUADS")
			tab1:SetWide(w / 3)
			tab1.DoSwitch = function()
				self.patrols:SetVisible(true)
				self.cameras:SetVisible(false)
			end

			local tab2 = test:Add("dispatch.window.tab")
			tab2:Dock(LEFT)
			tab2:SetWide(w / 3)
			tab2:SetText("CAMERAS")
			tab2.DoSwitch = function()
				self.patrols:SetVisible(false)
				self.cameras:SetVisible(true)
			end

			local tab3 = test:Add("dispatch.window.tabfunc")
			tab3:Dock(LEFT)
			tab3:SetWide(w / 3)
			tab3:SetText("DEPLOY SCANNER")
			tab3.DoClick = function()
				self:DeployScanner()
			end

			test.buttons[1] = tab1
			test.buttons[2] = tab2

			local container = frame:Insert("EditablePanel")
			container:Dock(TOP)
			container:SetTall((scrH - border_size * 2) / 2)
			container:InvalidateParent(true)

			local x2, y2, w2, h2 = container:GetBounds()

			self.patrols = container:Add("DScrollPanel")
			self.patrols:SetSize(w, h2)
			self.cameras = container:Add("DScrollPanel")
			self.cameras:SetSize(w, h2)

			frame:UpdateContainer()
		end

		gui.EnableScreenClicker(true)
		self:SetMouseInputEnabled(true)
		self:SetKeyboardInputEnabled(true)
		self:RequestFocus()

		self:BuildCameras()
		self:BuildSquads()

		hook.Add("OnSquadChangedLeader", "dispatch.ui", function(id, squad, character)
			self:OnSquadChangedLeader(id, squad, character)
		end)
		hook.Add("OnSquadMemberLeft", "dispatch.ui", function(id, squad, character)
			self:OnSquadMemberLeft(id, squad, character)
		end)
		hook.Add("OnSquadMemberJoin", "dispatch.ui", function(id, squad, character)
			self:OnSquadMemberJoin(id, squad, character)
		end)
		hook.Add("OnSquadDestroy", "dispatch.ui", function(id, squad)
			self:OnSquadDestroy(id, squad)
		end)
		hook.Add("OnSquadSync", "dispatch.ui", function(id, squad, full)
			self:OnSquadSync(id, squad, full)
		end)
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
	function PANEL:BuildCameras(data)
		for k, v in pairs(dispatch.FindCameras()) do
			local test = self.cameras:Add("dispatch.camera.button")
			test:Dock(TOP)
			test:DockMargin(0, 1, 16, 0)
			test:InvalidateParent(true)
			test:SetEntity(v)
		end
	end
	
	function PANEL:OnSpectate() end
	function PANEL:OnStopSpectate() end

	function PANEL:OnSquadSync(id, squad, full)
		self.squads[id]:SetupSquadFull(squad)

		self.manpower.stats[1]:SetValue(string.format("%i/15", #dispatch.squads - 1))
	end
	function PANEL:OnSquadDestroy(id, squad)
	end
	function PANEL:OnSquadMemberJoin(id, squad, character)
	end
	function PANEL:OnSquadMemberLeft(id, squad, character)
	end
	function PANEL:OnSquadChangedLeader(id, squad, character)
	end

	function PANEL:DeployScanner() 
		net.Start("dispatch.scanner")
		net.SendToServer()
	end
	function PANEL:SwitchStability() end
	function PANEL:RequestCamera(entity)
		net.Start("dispatch.spectate.request")
			net.WriteEntity(entity)
		net.SendToServer()
	end

	function PANEL:Paint(w, h)
		if !dispatch.IsSpectating(LocalPlayer()) then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(background)
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end

/*
	TO DO: IMPLEMENT PHOTO CAPTURE

	local Picture = {
		w = 580,
		h = 420,
		w2 = 580 * 0.5,
		h2 = 420 * 0.5,
		delay = 15
	}
	local startPicture = false
	local prepareScreen = false
	local x2, y2 = 0, 0
	hook.Add("HUDPaint", "Test", function()
		if !prepareScreen then
			return
		end
		
		local scrW, scrH = x2, y2
		local x, y = scrW - Picture.w2, scrH - Picture.h2

		local client = LocalPlayer()
		local scanner = client:GetViewEntity()
		local position = client:GetPos()
		local angle = client:GetAimVector():Angle()

		draw.SimpleText(string.format("ID (%s)", client:Name()), "ixScannerFont", x + 8, y + 40, color_white)

		surface.SetDrawColor(235, 235, 235, 230)
		surface.DrawLine(x, y, x + 128, y)
		surface.DrawLine(x, y, x, y + 128)

		x = scrW + Picture.w2

		surface.DrawLine(x, y, x - 128, y)
		surface.DrawLine(x, y, x, y + 128)

		x = scrW - Picture.w2
		y = scrH + Picture.h2

		surface.DrawLine(x, y, x + 128, y)
		surface.DrawLine(x, y, x, y - 128)

		x = scrW + Picture.w2

		surface.DrawLine(x, y, x - 128, y)
		surface.DrawLine(x, y, x, y - 128)

		surface.DrawLine(scrW - 48, scrH, scrW - 8, scrH)
		surface.DrawLine(scrW + 48, scrH, scrW + 8, scrH)
		surface.DrawLine(scrW, scrH - 48, scrW, scrH - 8)
		surface.DrawLine(scrW, scrH + 48, scrW, scrH + 8)
	end)


	hook.Add("PostRender", "test", function()
		if startPicture then
			local x = math.Clamp(x2 - Picture.w2, 0, ScrW())
			local y = math.Clamp(y2 - Picture.h2, 0, ScrH())
			
			local data = util.Compress(render.Capture({
				format = "jpeg",
				h = Picture.h,
				w = Picture.w,
				quality = 50,
				x = x,
				y = y
			}))

			net.Start("ScannerData2")
				net.WriteUInt(#data, 16)
				net.WriteData(data, #data)
			net.SendToServer()

			startPicture = false
			vgui.GetWorldPanel():SetVisible(true)
			timer.Simple(0, function() input.SetCursorPos(x2, y2) end)
		end
	end)

	local click = false
	function PANEL:Think() 
		x2, y2 = input.GetCursorPos()
		if input.IsKeyDown(KEY_LSHIFT) then
			prepareScreen = true

			if input.IsMouseDown(MOUSE_LEFT) and !click then
				click = true
				vgui.GetWorldPanel():SetVisible(false)
				
				startPicture = true
			elseif !input.IsMouseDown(MOUSE_LEFT) and click then
				click = false
			end
		else
			prepareScreen = false
		end
	end
*/

	vgui.Register("dispatch.main", PANEL, "EditablePanel")
end