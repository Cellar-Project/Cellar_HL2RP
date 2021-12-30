local PLUGIN = PLUGIN

function PLUGIN:CanPlayerEquipItem(client, item, slot)
	if IsValid(client) and client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end

function PLUGIN:CanPlayerViewInventory()
	print("CanPlayerViewInventory")
	if LocalPlayer():GetCharacter():GetData("zstage") == 3 then
		return false
	end
end

function PLUGIN:CanPlayerInteractItem(client, action)
	if IsValid(client) and client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end

function PLUGIN:CanPlayerInteractEntity(client, entity)
	if IsValid(client) and client:GetCharacter():GetData("zstage") == 3 then
		return false
	end
end
