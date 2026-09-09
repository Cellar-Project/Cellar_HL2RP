ix.infoMenu = {}
ix.infoMenu.stored = {}

function ix.infoMenu.Add(text)
	table.insert(ix.infoMenu.stored, text)
end

function ix.infoMenu.GetData()
	local character = LocalPlayer():GetCharacter()
	local faction = ix.faction.indices[LocalPlayer():Team()]

	hook.Run("SetInfoMenuData", character, faction)
end

function ix.infoMenu.Display()
	ix.infoMenu.stored = {}
	ix.infoMenu.GetData()

	ix.infoMenu.open = true
	ix.infoMenu.panel = vgui.Create("ixInfoMenu")
end

function ix.infoMenu.Remove()
	if (IsValid(ix.infoMenu.panel)) then
		ix.infoMenu.panel:Remove()
	end

	ix.infoMenu.panel = nil
	ix.infoMenu.open = false
end

-- ---------------------------------------------------------------------
-- Shared Cellar styling. The palette globals come from !sc_cellargui,
-- which loads first; the fallbacks keep this menu usable without it.
-- ---------------------------------------------------------------------
local function Blue() return cellar_blue or Color(56, 207, 248) end
local function BlurBlue() return cellar_blur_blue or Color(56, 61, 248, 225) end
local function Red() return cellar_red or Color(255, 30, 30, 225) end
local tint = Color(43, 157, 189, 43)

--- Draws Cellar glow text: a blurred additive pass under a sharp pass.
function ix.infoMenu.DrawText(text, font, x, y, color, alignX, alignY, blurColor)
	draw.SimpleText(text, font .. ".blur", x, y, blurColor or BlurBlue(), alignX, alignY)
	draw.SimpleText(text, font, x, y, color, alignX, alignY)
end

function ix.infoMenu.GetColors()
	return Blue(), Red()
end

--- Paints the translucent tinted box with blue edges used by the TAB menu panels.
function ix.infoMenu.PaintBox(w, h)
	local blue = Blue()

	draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 150))
	draw.RoundedBox(0, 0, 0, w, h, tint)
	draw.RoundedBox(0, 0, 0, 1, h, blue)
	draw.RoundedBox(0, w - 1, 0, 1, h, blue)
	draw.RoundedBox(0, 0, 0, w, 2, blue)
	draw.RoundedBox(0, 0, h - 2, w, 2, blue)
end

--- Paints the bracketed header bar (top rule, angled shoulders, centered title).
function ix.infoMenu.PaintHeader(text, w, h)
	local blue = Blue()
	local inset = w * 0.22
	local drop = math.min(h - 2, 14)

	draw.RoundedBox(0, 0, 0, w, 2, blue)
	draw.RoundedBox(0, inset + drop, drop, w - (inset + drop) * 2, 1, blue)

	surface.SetDrawColor(blue)
	surface.DrawLine(inset, 0, inset + drop, drop)
	surface.DrawLine(w - inset, 0, w - inset - drop, drop)

	ix.infoMenu.DrawText(text, "cellar.derma", w / 2, h / 2 + 4, blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- ---------------------------------------------------------------------
-- Glow label: sized from the sharp font, painted with both passes.
-- ---------------------------------------------------------------------
local LABEL = {}

function LABEL:Init()
	self.text = ""
	self.font = "cellar.derma.light"
	self.color = Blue()
	self.alignX = TEXT_ALIGN_LEFT
	self:SetMouseInputEnabled(false)
end

function LABEL:SetFont(font) self.font = font end
function LABEL:SetTextColor(color) self.color = color end
function LABEL:SetContentAlignment(alignment) self.alignX = alignment == 5 and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT end
function LABEL:GetText() return self.text end

function LABEL:SetText(text)
	self.text = text or ""

	-- Docked labels only care about height; skipping the resize when it is
	-- unchanged avoids a layout pass on every clock tick.
	surface.SetFont(self.font)
	local textW, textH = surface.GetTextSize(self.text)

	if (textH + 2 != self:GetTall()) then
		self:SetSize(textW + 8, textH + 2)
	end
end

function LABEL:SizeToContents()
	surface.SetFont(self.font)
	local textW, textH = surface.GetTextSize(self.text)
	self:SetSize(textW + 8, textH + 2)
end

function LABEL:Paint(w, h)
	if (self.alignX != TEXT_ALIGN_CENTER) then
		ix.infoMenu.DrawText(self.text, self.font, 4, h / 2, self.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		return
	end

	-- Nagonia digits are proportional, so a centered clock would shift with every
	-- second. Center on the width of a digit-normalized copy instead, then draw
	-- left-aligned from that fixed origin.
	surface.SetFont(self.font)
	local stableW = surface.GetTextSize((self.text:gsub("%d", "0")))
	ix.infoMenu.DrawText(self.text, self.font, (w - stableW) / 2, h / 2, self.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("ixInfoMenuLabel", LABEL, "Panel")

-- ---------------------------------------------------------------------
-- Menu frame
-- ---------------------------------------------------------------------
local PANEL = {}

DEFINE_BASECLASS("DFrame")

function PANEL:Init(logs)
	self.startTime = SysTime()
	self.noAnchor = CurTime() + 0.4
	self.anchorMode = true

	self:SetAlpha(0)
	self:SetSize(564, 64)
	self:ShowCloseButton(false)
	self:MakePopup()
	self:SetTitle("")
	self:DockPadding(8, 8, 8, 8)

	self:Populate()
	self.infoBox:InvalidateLayout(true)
	self.infoBox:SizeToChildren(false, true)
	self:BuildMenuPanel()
	self:SetPos((ScrW() * 0.5) - self:GetWide() * 0.5, (ScrH() * 0.25))

	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)

	self:AlphaTo(255, 0.5)
end

function PANEL:Populate()
	local faction = ix.faction.indices[LocalPlayer():Team()]

	self.rightContainer = self:Add("DPanel")
	self.rightContainer:Dock(RIGHT)
	self.rightContainer:SetWide(180)
	self.rightContainer:DockMargin(8, 0, 0, 0)
	self.rightContainer.Paint = function() end

	self.limbs = self.rightContainer:Add("ixLimbStatus")
	self.limbs:SetPos(0, 30)

	self.header = self:Add("Panel")
	self.header:Dock(TOP)
	self.header:SetTall(40)
	self.header:DockMargin(0, 0, 0, 8)
	self.header.text = L("Персонаж и ролевая информация"):utf8upper()
	self.header.Paint = function(this, w, h)
		ix.infoMenu.PaintHeader(this.text, w, h)
	end

	local format = "%A, %B %d, %Y. %H:%M:%S"

	self.time = self:Add(self:AddLabel(4, ix.date.GetFormatted(format), "cellar.mini"))
	self.time:SetContentAlignment(5)
	self.time.Think = function(this)
		if ((this.nextTime or 0) < CurTime()) then
			this:SetText(ix.date.GetFormatted(format))
			this.nextTime = CurTime() + 0.5
		end
	end

	self.infoBox = self:Add("DPanel")
	self.infoBox:Dock(TOP)
	self.infoBox:DockPadding(8, 8, 8, 8)
	self.infoBox.Paint = function(this, w, h)
		ix.infoMenu.PaintBox(w, h)
	end

	self.name = self.infoBox:Add(self:AddLabel(2, LocalPlayer():GetName():utf8upper(), "cellar.derma"))
	self.faction = self.infoBox:Add(self:AddLabel(8, faction.name, "cellar.derma.light"))

	for _, text in ipairs(ix.infoMenu.stored) do
		self.infoBox:Add(self:AddLabel(0, text, "cellar.mini"))
	end
end

function PANEL:BuildMenuPanel()
	self.menu = self:Add("ixInteractMenu")
	self.menu:Dock(TOP)
	self.menu:DockMargin(0, 8, 0, 0)

	for k, v in pairs(ix.quickmenu.stored) do
		if (v.shouldShow and v.shouldShow() == true) or !v.shouldShow then
			self.menu:AddOption(k, v)
		end
	end

	self.menu:Build()

	self.initialized = true
end

function PANEL:Paint(w, h)
	Derma_DrawBackgroundBlur(self, self.startTime)

	surface.SetDrawColor(0, 0, 0, 110)
	surface.DrawRect(0, 0, w, h)
end

function PANEL:AddLabel(margin, text, font)
	local label = self:Add("ixInfoMenuLabel")

	label:SetFont(font or "cellar.derma.light")
	label:SetText(text)
	label:Dock(TOP)
	label:DockMargin(0, 0, 0, margin)

	return label
end

function PANEL:OnKeyCodePressed(key)
	self.noAnchor = CurTime() + 0.5

	if (key == KEY_F1) then
		ix.infoMenu.Remove()
	end
end

function PANEL:Think()
	if (!IsValid(self.menu)) then
		ix.infoMenu.Remove()
	end

	local bTabDown = input.IsKeyDown(KEY_F1)

	if (bTabDown and (self.noAnchor or CurTime() + 0.4) < CurTime() and self.anchorMode) then
		self.anchorMode = false
	end

	if ((!self.anchorMode and !bTabDown) or gui.IsGameUIVisible()) then
		ix.infoMenu.Remove()
	end

	if (self.initialized and !self.menu.IsVisible) then
		ix.infoMenu.Remove()
	end
end

vgui.Register("ixInfoMenu", PANEL, "DFrame")
