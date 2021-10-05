if Discord.Backend then
    if os.time() < Discord.Backend.LastRefresh + 5 then
        Discord:Log('Preventing additional lua refresh that happened inside 5 seconds after last refresh.')
        return
    end

    if Discord.Backend.API then
        Discord.Backend.API:Destroy()
    end
end

Discord.Backend = {
    LastRefresh = os.time(),
}

local function RequestNewKey()
    Discord:Debug('Requesting new key...')
    net.Start('Discord_GetKey')
    net.SendToServer()
end

hook.Add('Think', 'Discord_GetKey', function()
    hook.Remove('Think', 'Discord_GetKey')

    RequestNewKey()
end)

function Discord.Backend:Connect()
    if not self.API then
        self.API = Discord.OOP:New('API')
        self.API:Init()

        self.API:once('open', function()
            hook.Run('Discord_Backend_Connected')
        end)

        self.API:on('request_key', function()
            RequestNewKey()
        end)

        self.API:on('payload_' .. Discord.OP.CONSOLE_MESSAGE, function(data)
            Discord:Log(data)
        end)
    end

    Discord:Debug('Connecting to the backend...')
    self.API:Connect()
end

function Discord:RPCInit()
    if not self.RPC then
        self.RPC = Discord.OOP:New('RPC')
        self.RPC:Init()
    end
end

net.Receive('Discord_GetKey', function(len)
    Discord:Debug('Received cl key')
    Discord.Backend.Key = net.ReadString()

    local extra = net.ReadBit()
    if extra then
        Discord.Backend = table.Merge(Discord.Backend, {
            HTTP_URL = net.ReadString(),
            Connector_URL = net.ReadString(),
            WebSocket_URL = net.ReadString(),
            EventSource_URL = net.ReadString(),
        })

        Discord.Config = util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))
    end

    Discord.Backend:Connect()
    Discord:RPCInit()
end)

concommand.Add('discord_reload', function()
    Discord:Log('Reloading...')
    RequestNewKey()
end)