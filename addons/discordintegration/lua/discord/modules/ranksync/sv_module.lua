Discord.ClientConfig.RankSync = {
    LinkConsoleCommand = Discord.Config.RankSync.LinkConsoleCommand,
    SyncConsoleCommand = Discord.Config.RankSync.SyncConsoleCommand,
}

local confirmationQueue = file.Exists('discord_integration/ranksync_queue.txt', 'DATA') and util.JSONToTable(util.Decompress(file.Read('discord_integration/ranksync_queue.txt', 'DATA'))) or {}
local function RequeueConfirmations()
    if #confirmationQueue > 0 then Discord:Log('Requeueing unconfirmed rank sync requests...') end
    for _, d in ipairs(confirmationQueue) do
        Discord:Debug('Unconfirmed nonce ' .. d.nonce .. ' for rank sync, resending...')
        Discord.Backend.API:Send({
            op = Discord.OP.RANK_SYNC,
            d = d,
        })
    end
end
RequeueConfirmations()
Discord.Backend.API:on('connected', RequeueConfirmations, 'Discord_RankSync')

local function SaveQueue()
    file.Write('discord_integration/ranksync_queue.txt', util.Compress(util.TableToJSON(confirmationQueue)))
end

function Discord:SyncRanks(ply)
    Discord.Backend.API:Send({
        op = Discord.OP.RANK_SYNC,
        d = {
            nonce = Discord.Backend.API:GetNonce(), -- manual rank sync isn't as important as demotion/promotion, don't save to queue
            sid64 = ply:SteamID64(),
            old = ply:GetUserGroup(),
            new = ply:GetUserGroup(),
            manual = true,
        },
    })
end

local ratelimits = {}
util.AddNetworkString('Discord_RankSync_Activate')
hook.Add('PlayerSay', 'Discord_RankSync', function(ply, text, team)
    if string.StartWith(text, Discord.Config.RankSync.LinkChatCommand) then
        -- already ratelimited cl
        net.Start('Discord_RankSync_Activate')
        net.Send(ply)

        return ''
    elseif string.StartWith(text, Discord.Config.RankSync.SyncChatCommand) then
        local sid64 = ply:SteamID64()
        if ratelimits[sid64] then
            Discord.Util:PlyChat(ply, Discord.Util:GetLang('RATELIMITED', {
                seconds = math.floor(ratelimits[sid64] - CurTime()),
            }))
            return ''
        end

        ratelimits[sid64] = CurTime() + 5
        timer.Simple(5, function()
            ratelimits[sid64] = nil
        end)

        Discord:SyncRanks(ply)

        return ''
    end
end)

local ratelimits2 = {}
net.Receive('Discord_RankSync_Activate', function(len, ply)
    local sid64 = ply:SteamID64()
    if ratelimits2[sid64] then
        return -- Bypassing cl ratelimit, he doesn't need message as he's abusing
    end

    ratelimits2[sid64] = CurTime() + 5
    timer.Simple(5, function()
        ratelimits2[sid64] = nil
    end)

    Discord:SyncRanks(ply)
end)

local failsafe = {}
local function SyncDiscordRank(sid64, old, new)
    if not Discord.Config.RankSync.GmodToDiscord then return end

    old = old or 'user'
    if failsafe[sid64] and failsafe[sid64] == new then
        failsafe[sid64] = nil
        return Discord:Debug('Failsafe triggered for ' .. sid64 .. ': ' .. old .. ' -> ' .. new)
    end

    local d = {
        nonce = Discord.Backend.API:GetNonce(),
        sid64 = sid64,
        old = old,
        new = new,
    }

    Discord:Log('Sending rank sync request for ' .. sid64 .. ': ' .. old .. ' -> ' .. new .. ' [' .. d.nonce .. ']')
    table.insert(confirmationQueue, d)
    SaveQueue()

    Discord.Backend.API:Send({
        op = Discord.OP.RANK_SYNC,
        d = d,
    })
end

hook.Add('CAMI.PlayerUsergroupChanged', 'Discord_RankSync', function(ply, old, new, adminmod)
    if not ply or not IsValid(ply) then return end

    SyncDiscordRank(ply:SteamID64(), old, new)
end)

hook.Add('CAMI.SteamIDUsergroupChanged', 'Discord_RankSync', function(anything, old, new, adminmod)
    local sid64
    if anything:match("^7656119%d+$") then
        sid64 = anything
    elseif anything:upper():match("^STEAM_%d:%d:%d+$") then
        sid64 = util.SteamIDTo64(anything)
    else
        -- because who knows what CAMI will return
        -- imagine if people followed the specification, ulx can return sid, sid64, or even player ip...
        return
    end

    SyncDiscordRank(sid64, old, new)
end)

local function SetUserGroup(sid64, usergroup) -- CAMI plz
    Discord:Log('Received rank sync for ' .. sid64 .. ': Setting usergroup to ' .. usergroup)

    failsafe[sid64] = usergroup
    timer.Simple(3, function()
        if failsafe[sid64] then failsafe[sid64] = nil end
    end)

    local sid = util.SteamIDFrom64(sid64)
    if ULib then
        ULib.ucl.addUser(sid, nil, nil, usergroup)
    elseif serverguard then
        local ply = player.GetBySteamID(sid)
        if ply then
            local rankData = serverguard.ranks:GetRank(usergroup)
            serverguard.player:SetRank(ply, usergroup)
            serverguard.player:SetImmunity(ply, rankData.immunity)
            serverguard.player:SetTargetableRank(ply, rankData.targetable)
            serverguard.player:SetBanLimit(ply, rankData.banlimit)
        else
            serverguard.player:SetRank(sid, usergroup)
        end
    elseif D3A then -- provided D3A has CAMI support, this'll work
        D3A.Ranks.SetSteamIDRank(sid, usergroup)
    elseif FAdmin then
        RunConsoleCommand("fadmin", "setaccess", sid, usergroup)
    elseif Mercury then
        RunConsoleCommand("hg", "setrank", sid, usergroup)
    elseif maestro then
        maestro.userrank(sid64, usergroup)
    elseif xAdmin then
        RunConsoleCommand("xadmin_setgroup", sid, usergroup) -- Run console command to handle notifying user, admins and console
    elseif sam then
        sam.player.set_rank_id(sid, usergroup)
    else
        Discord:Log('Failed setting usergroup for ' .. sid64 .. ': No compatible admin mods were found.')
        return
    end
end

Discord.Backend.API:on('payload_' .. Discord.OP.RANK_SYNC, function(data)
    for _, sid64 in ipairs(data.accounts) do
        SetUserGroup(sid64, data.usergroup)
    end

    Discord.Backend.API:Send({
        op = Discord.OP.RANK_SYNC_NONCE,
        d = {
            nonce = data.nonce,
        },
    })
end, 'Discord_RankSync')

Discord.Backend.API:on('payload_' .. Discord.OP.RANK_SYNC_NONCE, function(data)
    local nonce = data.nonce
    for i, d in ipairs(confirmationQueue) do
        if d.nonce == nonce then
            Discord:Debug('Received rank sync confirmation for nonce ' .. nonce)
            table.remove(confirmationQueue, i)
            SaveQueue()
            break
        end
    end
end, 'Discord_RankSync')