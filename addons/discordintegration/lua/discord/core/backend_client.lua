util.AddNetworkString('Discord_GetKey')

Discord.ClientConfig = Discord.ClientConfig or {
    ClientID = Discord.Config.ClientID,
}

local keyCache = {}
local keyQueue = {}
hook.Add('Discord_Backend_Reauth', 'Discord_GetKey', function()
    keyCache = {}
    -- Reset cache (in case all keys get expired, even though this is highly unlikely)
end)

hook.Add('PlayerDisconnected', 'Discord_GetKey', function(ply)
    local sid64 = ply:SteamID64()
    if not keyCache[sid64] then return end

    timer.Destroy('Discord_ExpireKey_' .. sid64)
    keyCache[sid64] = nil

    Discord.Backend.API:Send({
        op = Discord.OP.UNREGISTER_KEY,
        d = sid64,
    })
end)

local function sendKey(ply, key)
    net.Start('Discord_GetKey')
        net.WriteString(key)

        net.WriteBit(not ply._sentDiscordIntegration and 1 or 0)
        if not ply._sentDiscordIntegration then
            ply._sentDiscordIntegration = true
            
            net.WriteString(Discord.Backend.HTTP_URL)
            net.WriteString(Discord.Backend.Connector_URL)
            net.WriteString(Discord.Backend.WebSocket_URL)
            net.WriteString(Discord.Backend.EventSource_URL)
            
            local config = util.Compress(util.TableToJSON(Discord.ClientConfig))
            net.WriteUInt(#config, 16)
            net.WriteData(config, #config)
        end
    net.Send(ply)
end

local function handleKeyQueue()
    for _, sid64 in ipairs(keyQueue) do
        Discord:Debug('Registering key for ' .. sid64)
        Discord.Backend.API:Send({
            op = Discord.OP.REGISTER_KEY,
            d = sid64,
        })
    end
    keyQueue = {}
end

net.Receive('Discord_GetKey', function(len, ply)
    if not ply or not IsValid(ply) then return end

    local sid64 = ply:SteamID64()
    if keyCache[sid64] then
        sendKey(ply, keyCache[sid64])
    else
        if Discord.Backend.API then
            Discord:Debug('Registering key for ' .. sid64)
            Discord.Backend.API:Send({
                op = Discord.OP.REGISTER_KEY,
                d = sid64,
            })
        else
            table.insert(keyQueue, sid64)
        end
    end
end)

hook.Add('Discord_Backend_Connected', 'Discord_GetKey', function()
    Discord.Backend.API:on('payload_' .. Discord.OP.REGISTER_KEY, function(d)
        local sid64 = d.sid64
        local key = d.key

        Discord:Debug('Received the key for ' .. sid64)

        local ply = player.GetBySteamID64(sid64)
        if not ply or not IsValid(ply) then
            timer.Destroy('Discord_ExpireKey_' .. sid64)
            keyCache[sid64] = nil

            Discord.Backend.API:Send({
                op = Discord.OP.UNREGISTER_KEY,
                d = sid64,
            })
            return
        end

        keyCache[sid64] = key
        timer.Create('Discord_ExpireKey_' .. sid64, 6 * 60 * 60, 1, function()
            keyCache[sid64] = nil
        end)

        sendKey(ply, key)
    end)

    Discord.Backend.API:on('connected', handleKeyQueue)
    handleKeyQueue()
end)