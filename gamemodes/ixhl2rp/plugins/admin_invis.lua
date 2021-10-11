local PLUGIN = PLUGIN or {}

PLUGIN.name = "Admin absolute invisibility"
PLUGIN.author = "maxxoft"
PLUGIN.description = "Admin invisilibity for anti-hacking purposes."


ix.command.Add("Invis", {
	description = "Invis.",
	adminOnly = true,
	OnRun = function(self, client)
		if client:GetNetVar("invis") == nil or
		   client:GetNetVar("invis") == false then
			client:SetNetVar("invis", true)
			state = true
		elseif !client:GetNetVar("invis") then
			client:SetNetVar("invis", false)
			state = false
		for _, ply in pairs(player:GetAll()) do
			client:SetPreventTransmit(ply, state)
			for _, child in pairs(client:GetChildren()) do
				if !ply:IsAdmin() then
					child:SetPreventTransmit(ply, state)
				end
			end
		end
	end
})