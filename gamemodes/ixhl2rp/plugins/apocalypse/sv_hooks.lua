local PLUGIN = PLUGIN

function PLUGIN:CanPlayerEquipItem(client, item, slot)
    if IsValid(client) and client:GetData("zombie", false) then
        return false
    end
end

function PLUGIN:CanPlayerViewInventory() -- client-side
end

function PLUGIN:CanPlayerInteractItem(client, action)
    if IsValid(client) and client:GetData("zombie", false) then
        return false
    end
end

function PLUGIN:CanPlayerInteractEntity(client, entity)
    if IsValid(client) and client:GetData("zombie", false) then
        return false
    end
end