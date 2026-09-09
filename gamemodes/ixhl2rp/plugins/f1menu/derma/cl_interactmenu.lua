local PANEL = {}

local OPTION_TALL = 28
local OPTION_FONT = "cellar.mini"

function PANEL:Init()
	if (IsValid(ix.gui.interactMenu)) then
		ix.gui.interactMenu:Destroy()
	end

	ix.gui.interactMenu = self

	self:DockPadding(6, 8, 6, 8)
	self.options = {}
end

function PANEL:Build()
	self:SetWide(128)
	self:SetTall(16 + #self.options * OPTION_TALL)
end

function PANEL:AddOption(k, v)
	local option = self:Add("DButton")
	option:SetText("")
	option:Dock(TOP)
	option:SetTall(OPTION_TALL)

	option.Paint = function(this, w, h)
		local blue, red = ix.infoMenu.GetColors()
		local hovered = this:IsHovered()

		if (hovered) then
			draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(blue, 25))
			draw.RoundedBox(0, 0, 0, 2, h, red)
		end

		local color = hovered and red or blue
		ix.infoMenu.DrawText(v.name, OPTION_FONT, 30, h / 2, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, hovered and red or nil)
	end

	option.OnCursorEntered = function()
		LocalPlayer():EmitSound("Helix.Rollover")
	end

	option.DoClick = function()
		LocalPlayer():EmitSound("Helix.Press")

		if (v.callback) then
			v.callback()
		end

		self:Destroy()
	end

	if (v.icon) then
		local icon = option:Add("DImage")
		icon:SetSize(16, 16)
		icon:SetPos(8, (OPTION_TALL - 16) / 2)
		icon:SetMaterial(Schema.assets.Material(v.icon))
		icon.AutoSize = false
	end

	table.insert(self.options, option)
end

function PANEL:Destroy()
	self:Remove()
	ix.gui.interactMenu = nil
end

function PANEL:Paint(w, h)
	ix.infoMenu.PaintBox(w, h)
end

vgui.Register("ixInteractMenu", PANEL, "DPanel")
