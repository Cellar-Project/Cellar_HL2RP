local PLUGIN = PLUGIN

local PANEL = {}
PANEL.backgroundColor = Color(0, 0, 0, 66)

function PANEL:Init()
	if IsValid(ix.gui.squads) then
		ix.gui.squads:Remove()
	end

	ix.gui.squads = self

	self:Dock(FILL)

	self.teamsPanel = self:Add("ixHelpMenuCategories")
	self.teamsPanel.Paint = function(this, width, height)
		surface.SetDrawColor(self.backgroundColor)
		surface.DrawRect(0, 0, width, height)
	end

	local createButton = self.teamsPanel:Add("ixMenuButton")
	createButton:SetText("CREATE SQUAD")
	createButton:SizeToContents()
	createButton:SetZPos(-99)
	createButton:Dock(BOTTOM)
	createButton.DoClick = function()
		ix.command.Send("SquadCreate")
	end

	self.teamsPanel:SizeToContents()
end
vgui.Register("ixSquadManager", PANEL, "EditablePanel")

hook.Add("CreateMenuButtons", "ixSquadManager", function(tabs)
	if !LocalPlayer():IsCombine() then 
		return 
	end

	tabs["tabSquads"] = function(container)
		container:Add("ixSquadManager")
	end
end)