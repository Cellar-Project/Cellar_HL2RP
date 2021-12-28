local PLUGIN = PLUGIN


function PLUGIN:CanPlayerViewInventory()
	if LocalPlayer():GetCharacter():GetData("zombie", false) then
		return false
	end
end