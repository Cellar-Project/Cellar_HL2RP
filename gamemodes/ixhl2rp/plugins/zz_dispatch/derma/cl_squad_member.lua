-- TO DO: CLEAN UP THINGS, ACTIONS MENU FOR AI/SQUAD LEADER, MAKE LABELS WORK

local PANEL = {}
local focus_color = Color(0, 0, 0, 225)
local header_colors = {
	{Color(0, 255, 255), Color(0, 255, 255, 19)},
	{Color(251, 213, 0), Color(251, 213, 0, 19)},
	{Color(255, 29, 93), Color(255, 29, 93, 19)},
}
local code_colors = {
	{Color(102, 255, 102), Color(102, 255, 102, 38)},
	{Color(251, 213, 0), Color(251, 213, 0, 38)},
	{Color(255, 29, 93), Color(255, 29, 93, 38)},
}
local area_color = {Color(255, 255, 255), Color(255, 255, 255, 45)}

function PANEL:GetHeaderColor(isText)
	return (self.hovered and isText) and focus_color or (self.hovered and header_colors[1][1] or (isText and header_colors[1][1] or header_colors[1][2]))
end

function PANEL:GetCodeColor(isText)
	return (self.hovered and isText) and focus_color or (self.hovered and code_colors[1][1] or (isText and code_colors[1][1] or code_colors[1][2]))
end

function PANEL:GetAreaColor(isText)
	return (self.hovered and isText) and focus_color or (self.hovered and area_color[1] or (isText and area_color[1] or area_color[2]))
end

function PANEL:GetTextColors()
	self.text:SetTextColor(self:GetHeaderColor(true))
	self.hp:SetTextColor(self:GetHeaderColor(true))
	self.code_text:SetTextColor(self:GetCodeColor(true))
	self.area_text:SetTextColor(self:GetAreaColor(true))
end

function PANEL:PaintMain(w, h)
	surface.SetDrawColor(self.parent:GetHeaderColor())
	surface.DrawRect(0, 0, w, h)
end

function PANEL:PaintCode(w, h)
	surface.SetDrawColor(self.parent:GetCodeColor())
	surface.DrawRect(0, 0, w, h)
end

function PANEL:PaintPos(w, h)
	surface.SetDrawColor(self.parent:GetAreaColor())
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Init()
	self:SetText("")
	self:SetTall(25)

	self.tag = "ERROR-1"
	self.hovered = false

	self.area = self:Add("Panel")
	self.area:Dock(RIGHT)
	self.area:DockMargin(2, 0, 0, 0)
	self.area:SetMouseInputEnabled(false)
	
	self.area_text = self.area:Add("DLabel")
	self.area_text:Dock(FILL)
	self.area_text:SetContentAlignment(5)

	self.code = self:Add("Panel")
	self.code:Dock(RIGHT)
	self.code:DockMargin(2, 0, 0, 0)
	self.code:SetMouseInputEnabled(false)

	self.code_text = self.code:Add("DLabel")
	self.code_text:Dock(FILL)
	self.code_text:SetContentAlignment(5)

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

	self.hp = self.header:Add("DLabel")
	self.hp:DockMargin(0, 0, 5, 0)
	self.hp:Dock(RIGHT)
	self.hp:SetContentAlignment(6)

	self.hp:SetFont("dispatch.camera.button")
	self.text:SetFont("dispatch.camera.button")
	self.code_text:SetFont("dispatch.camera.button")
	self.area_text:SetFont("dispatch.camera.button")

	self.area.parent = self
	self.code.parent = self
	self.header.parent = self

	self.area.Paint = self.PaintPos
	self.code.Paint = self.PaintCode
	self.header.Paint = self.PaintMain
end

function PANEL:OnCursorEntered()
	self.hovered = true

	self:GetTextColors()
end

function PANEL:OnCursorExited()
	self.hovered = false

	self:GetTextColors()
end

function PANEL:PerformLayout(w, h)

	self.code:SetWide(w * 0.15)
	self.area:SetWide(w * 0.25)

	self.header:SetWide(w - self.area:GetWide() - self.code:GetWide())
end

function PANEL:GetSquad()
	return self:GetParent():GetParent().squad
end

function PANEL:SetCharacter(char)
	local squad = self:GetSquad()
	local rank = ix.class.list[char:GetClass()].tag

	self.tag = string.format("%s%s-%i", rank and rank.."." or "", squad:GetTagName(), squad.members[char] or 0)

	self.text:SetText(self.tag)

	self:GetTextColors()
end

vgui.Register("squad.member.button", PANEL, "DButton")