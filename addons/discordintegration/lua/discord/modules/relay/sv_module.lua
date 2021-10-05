Discord.ClientConfig.Relay = {
    RelayDiscord = Discord.Config.Relay.RelayDiscord,
    PreventGhosting = Discord.Config.Relay.PreventGhosting,
}

if not Discord_OnlineMessageSent and Discord.Config.Relay.SendOnlineMessage then
    Discord.Backend.API:Send(
        Discord.OOP:New('Message'):SetChannel('Relay'):SetEmbed({
            color = 0x2ecc71,
            title = Discord.Util:GetLang('ONLINE_MESSAGE_TITLE'),
            description = Discord.Util:GetLang('ONLINE_MESSAGE_DESCRIPTION'),
        }):ToAPI()
    )

    Discord_OnlineMessageSent = true
end

local joinAntiSpam = {}
gameevent.Listen('player_connect')
hook.Add('player_connect', 'Discord_Connect', function(data)
    if not Discord.Config.Relay.RelayJoinLeave then return end
    if data.networkid == 'BOT' and Discord.Config.Relay.IgnoreBots then return end
    if joinAntiSpam[data.networkid] and joinAntiSpam[data.networkid] > CurTime() then return end
    joinAntiSpam[data.networkid] = CurTime() + 5

    Discord.Backend.API:Send(
        Discord.OOP:New('Message'):SetChannel('Relay'):SetEmbed({
            color = 0x2ecc71,
            description = Discord.Util:GetLang('PLAYER_JOIN', {
                steam_id = data.networkid,
                name = data.name,
                reason = data.reason,
            }),
        }):ToAPI()
    )
end)

local leaveAntiSpam = {}
gameevent.Listen('player_disconnect')
hook.Add('player_disconnect', 'Discord_Disconnect', function(data)
    if not Discord.Config.Relay.RelayJoinLeave then return end
    if data.networkid == 'BOT' and Discord.Config.Relay.IgnoreBots then return end
    if leaveAntiSpam[data.networkid] and leaveAntiSpam[data.networkid] > CurTime() then return end
    leaveAntiSpam[data.networkid] = CurTime() + 5

    Discord.Backend.API:Send(
        Discord.OOP:New('Message'):SetChannel('Relay'):SetEmbed({
            color = 0xe74c3c,
            description = Discord.Util:GetLang('PLAYER_DISCONNECT', {
                steam_id = data.networkid,
                name = data.name,
                reason = data.reason,
            }),
        }):ToAPI()
    )
end)

hook.Add('PlayerSay', 'Discord_SendChat', function(ply, text, team)
    if not Discord.Config.Relay.RelayChat then return end
    if not ply or not IsValid(ply) then return end
    if ulx and (ply.gimp and ply.gimp == 2) then return end -- ULX Mute
    
    local shouldRelay = hook.Run('Discord_ShouldRelay', ply, text, team)
    if shouldRelay == false then return end

    local parsedText = hook.Run('Discord_ParseText', text, ply)
    if parsedText ~= nil then text = parsedText end

    -- Some addons return enum for team var
    local parsedTeam = hook.Run('Discord_ParseTeam', team)
    if parsedTeam ~= nil then team = parsedTeam end

    if #Discord.Config.Relay.WhitelistedCommands > 0 then
        local canrelay = false
        for _, cmd in pairs(Discord.Config.Relay.WhitelistedCommands) do
            if string.StartWith(text, cmd) then
                text = string.sub(text, #cmd + 1)
                canrelay = true
                break
            end
        end
        if not canrelay then return end
    else
        for _, cmd in pairs(Discord.Config.Relay.BlockedCommands) do
            if string.StartWith(text, cmd) then return end
        end
    end

    if engine.ActiveGamemode() == 'terrortown' then
        if GetRoundState() == ROUND_ACTIVE then
            if ply:IsTraitor() and team or ply:IsDetective() and team then return end

            if not ply:Alive() and Discord.Config.Relay.PreventGhosting then return end
        end
    end

    if not Discord.Config.Relay.TeamChatEnabled and team then return end

    local plyNick = Discord.Config.Relay.NamePrefix .. (ply:Nick() or ply:Name())
    if string.len(plyNick) > 32 then plyNick = string.sub(plyNick, 1, 29) .. '...' end

    text = string.sub(text, 0, 2047)

    Discord.Backend.API:Send({
        op = Discord.OP.RELAY_MESSAGE,
        d = {
            nick = plyNick,
            sid64 = ply:SteamID64(),
            text = text,
        },
    })
end)

Discord.Commands = Discord.Commands or {}
function Discord:RegisterCommand(name, callback)
    Discord.Commands[name] = callback
end

local function parseArgs(str)
    local ret = {}
    local InString = false
    local strchar = ''
    local chr = ''
    local escaped = false

    for i = 1, #str do
        local char = str[i]
        if escaped then chr = chr .. char escaped = false continue end
        if char:find('["|\']') and not InString and not escaped then
            InString = true
            strchar = char
        elseif char:find('[\\]') then
            escaped = true
            continue
        elseif InString and char == strchar then
            table.insert(ret, chr:Trim())
            chr = ''
            InString = false
        elseif char:find('[ ]') and not InString then
            if chr ~= '' then table.insert(ret, chr) chr = '' end
        else
            chr = chr .. char
        end
    end
    if chr:Trim():len() ~= 0 then table.insert(ret, chr) end
    return ret
end

Discord.Backend.API:on('payload_' .. Discord.OP.COMMAND, function(data)
    Discord:Debug('Received command ' .. data.command .. ' - ' .. data.author.nickname .. ': ' .. data.raw)

    if Discord.Commands[data.command] then
        data.args = parseArgs(data.argstr)
        Discord.Commands[data.command](data)
    end
end, 'commandHandler')