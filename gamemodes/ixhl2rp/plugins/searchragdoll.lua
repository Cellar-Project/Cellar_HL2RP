local PLUGIN = PLUGIN

PLUGIN.name = "Ragdoll Search"
PLUGIN.author = "maxxoft"
PLUGIN.description = ""


if SERVER then
    util.AddNetworkString('SearchRagdoll')

    net.Receive('SearchRagdoll', function(len, ply)
        local doll = net.ReadEntity()
        local data = {}
            data.start = ply:GetShootPos()
            data.endpos = data.start + ply:GetAimVector() * 96
            data.filter = ply
        local target = util.TraceLine(data).Entity
        local clientTarget = IsValid(target.ixPlayer) and target.ixPlayer or target
        if doll != target then return end


        local inventory = clientTarget:GetCharacter():GetInventory()
        ix.storage.Open(ply, inventory, {
            entity = clientTarget,
            name = clientTarget:GetName(),
            searchTime = 0
        })

    end)

else
    net.Receive('RagdollMenu', function(len, player)
        local ply = Entity(net.ReadUInt(32))
        local doll = Entity(net.ReadUInt(32))
        function doll:GetEntityMenu()
            local options = {
                ["Обыскать"] = function()
                    net.Start('SearchRagdoll')
                        net.WriteEntity(self)
                    net.SendToServer()
                    return false
                end
            }
            return options
        end
    end)
end
