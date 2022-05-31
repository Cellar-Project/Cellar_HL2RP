
net.Receive("ixFoodConservation", function()
	local item = ix.item.instances[net.ReadUInt(32)]
	local dateToSet = net.ReadUInt(32)
	local timeLeftToSet = net.ReadUInt(32)

	item:SetData("expirationDate", dateToSet)
	item:SetData("expirationTimeLeft", timeLeftToSet != 0 and timeLeftToSet or nil)
end)
