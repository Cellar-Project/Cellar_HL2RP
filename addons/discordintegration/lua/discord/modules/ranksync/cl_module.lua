local ratelimit = 0
function Discord:LinkAccount()
    if ratelimit > CurTime() then
        Discord:Chat(Discord.Util:GetLang('RATELIMITED', {
            seconds = math.floor(ratelimit - CurTime()),
        }))
        return
    end

    ratelimit = CurTime() + 5

    if not Discord.RPC.discovered then
        Discord:Chat(Discord.Util:GetLang('DISCORD_NOT_FOUND'))
        gui.OpenURL(Discord.Backend.HTTP_URL .. 'auth/discord?token=' .. Discord.Backend.Key .. '&op=' .. Discord.OP.LINK_ACCOUNT)
        return
    end

    Discord:Chat(Discord.Util:GetLang('CHECK_DISCORD'))
    Discord.RPC:Request({'identify', 'connections'}, Discord.Config.ClientID, function(err, data)
        if err and string.find(err, 'OAuth2 Error: access_denied: unknown error') then
            Discord:Chat(Discord.Util:GetLang('RPC_ABORTED'))
            return
        end

        if err or not data.code then
            Discord:Error(err or util.TableToJSON(data))
            Discord:Chat(Discord.Util:GetLang('SOMETHING_WENT_WRONG'))
            return
        end

        Discord.Backend.API:Send({
            op = Discord.OP.LINK_ACCOUNT,
            d = data.code,
        })
    end)
end

net.Receive('Discord_RankSync_Activate', Discord.LinkAccount)
concommand.Add(Discord.Config.RankSync.LinkConsoleCommand, Discord.LinkAccount)

local ratelimit2 = 0
concommand.Add(Discord.Config.RankSync.SyncConsoleCommand, function()
    if ratelimit2 > CurTime() then
        Discord:Chat(Discord.Util:GetLang('RATELIMITED', {
            seconds = math.floor(ratelimit - CurTime()),
        }))
        return
    end

    ratelimit2 = CurTime() + 5

    net.Start('Discord_RankSync_Activate')
    net.SendToServer()
end)

Discord.Backend.API:on('payload_' .. Discord.OP.LINK_ACCOUNT, function(data)
    Discord:Chat(Discord.Util:GetLang('CONNECTIONS_NOT_FOUND'))
    gui.OpenURL(data)
end, 'linkaccount')