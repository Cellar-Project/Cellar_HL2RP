
-- blur clients screen if head is hurt
function PLUGIN:RenderScreenspaceEffects()
	local hDamageFraction = self:GetLimbsDamage(LocalPlayer(), true, "head")[1]

	if (isnumber(hDamageFraction)) then
		ix.util.DrawBlurAt(0, 0, ScrW(), ScrH(), nil, nil, hDamageFraction * 255)
	end
end

-- replicate prone enter on client
net.Receive("ixLimbsPenaltiesProne", function()
	prone.Enter(LocalPlayer())
end)
