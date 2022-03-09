-- TO DO: CLEAN UP THINGS

surface.CreateFont("ixSquadTitle", {
	font = "Blender Pro Bold",
	extended = true,
	size = 20,
	weight = 500,
	antialias = true
})
surface.CreateFont("ixSquadMember", {
	font = "Roboto Medium",
	extended = true,
	size = 12,
	weight = 500,
	antialias = true
})
surface.CreateFont("ixSquadTitleSmall", {
	font = "Blender Pro Medium",
	extended = true,
	size = 15,
	weight = 500,
	antialias = true
})

local PANEL = {}
PANEL.HeaderSize = 28
PANEL.clr = {
	Color(0, 240, 255, 255),
	Color(0, 0, 0, 255),
	Color(255, 255, 255, 200),
	Color(255, 255, 255)
}

function PANEL:Init()
	self.HeaderSize = PANEL.HeaderSize

	self.header = self:Add("Panel")
	self.header:Dock(TOP)
	self.header:SetTall(PANEL.HeaderSize)
	self.header.Paint = function(_, w, h)
		self:HeaderPaint(w, h)
	end

	self.btn = self.header:Add("DButton")
	self.btn:Dock(FILL)
	self.btn:SetText("")
	self.btn.Paint = function() end
	self.btn.DoClick = function()
		self:OnExpand()
	end

	self.join = self.header:Add("DButton")
	self.join:Dock(RIGHT)
	self.join:SetText("")
	self.join:SetWide(24)
	self.join.Paint = function(_, w, h)
		self:JoinPaint(w, h, _)
	end

	self.join.DoClick = function()
		self:OnJoin()
	end

	self.subcontainer = self:Add("Panel")
	self.subcontainer:Dock(FILL)
	self.subcontainer:DockMargin(0, 0, 0, 0)

	self:SetTall(PANEL.HeaderSize)

	self.squad = nil
	self.expanded = false
	self.targetSize = PANEL.HeaderSize
	self.lastTargetSize = self.targetSize
	self.members = {}
end

function PANEL:OnExpand()
	self:SizeTo(-1, self.expanded and PANEL.HeaderSize or self.targetSize, 0.025, 0, -1, function()
		self.expanded = !self.expanded
	end)
end

function PANEL:OnJoin()
end

function PANEL:RemoveMember(char)
	self.members[char]:Remove()
	self.members[char] = nil

	self.subcontainer:InvalidateLayout(true)
	self.subcontainer:SizeToChildren(false, true)

	self.targetSize = PANEL.HeaderSize + self.subcontainer:GetTall()

	self:SetTall(self.targetSize)

	self.lastTargetSize = self.targetSize
end

function PANEL:AddMember(char)
	local a = self.subcontainer:Add("squad.member.button")
	a:DockMargin(0, 2, 0, 0)
	a:Dock(TOP)
	a:SetCharacter(char)

	self.subcontainer:InvalidateLayout(true)
	self.subcontainer:SizeToChildren(false, true)

	self.targetSize = PANEL.HeaderSize + self.subcontainer:GetTall()
	self.lastTargetSize = self.targetSize
end

function PANEL:SetupSquad(tag)
	if tag == 1 then
		self.isStatic = true
	end
	
	self.squad_tag = tag
	self.squad = nil
	self.data = {
		name = "",
		count = 0
	}

	self:SetVisible(false)
end

function PANEL:SetupSquadFull(squad)
	if squad.isStatic then
		self.isStatic = true
	end

	self.squad = squad
	self.data = {
		name = self.isStatic and "UNASSIGNED" or "SQUAD "..squad:GetTagName(),
		count = squad:GetLimitCount(),
		format = "%i / "..(self.isStatic and "∞" or "5")
	}

	for char, _ in pairs(squad.members) do
		self.members[char] = self:AddMember(char)
	end

	self:UpdateSquadInfo()
end

function PANEL:UpdateSquadInfo()
	self.data.count = self.squad:GetLimitCount()
end

function PANEL:JoinPaint(w, h, btn)
	draw.SimpleText("+", "ixSquadTitle", w / 2, h / 2, btn:IsHovered() and self.clr[4] or self.clr[1], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:HeaderPaint(w, h)
	surface.SetDrawColor(self.clr[1])
	surface.DrawRect(0, h - 1, w, 1)

	draw.SimpleText(self.data.name, "ixSquadTitle", 8, h / 2, self.clr[1], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(string.format(self.data.format, self.data.count), "ixSquadTitleSmall", w - 72, h / 2, self.clr[1], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

vgui.Register("squadCategoryBtn", PANEL, "EditablePanel")
