Discord.ClientConfig.JoinRewards = {
    ConsoleCommand = Discord.Config.JoinRewards.ConsoleCommand,
    GuildID = Discord.Config.JoinRewards.GuildID,
    PopupOnJoin = Discord.Config.JoinRewards.PopupOnJoin,
    OneTime = Discord.Config.JoinRewards.OneTime,
}

util.AddNetworkString('Discord_JoinRewards_Activate')
hook.Add('PlayerSay', 'Discord_JoinRewards', function(ply, text, team)
    if string.StartWith(text, Discord.Config.JoinRewards.ChatCommand) then
        net.Start('Discord_JoinRewards_Activate')
        net.Send(ply)

        return ''
    end
end)

util.AddNetworkString('Discord_JoinDiscord')
Discord.Backend.API:on('payload_' .. Discord.OP.JOIN_DISCORD, function(data)
    local already_joined = data.already_joined
    local sid64 = data.sid64
    local discord_id = data.discord_id

    Discord:Debug('Received join confirmation for ' .. sid64 .. ' with the discord account ' .. discord_id .. '! [First time: ' .. (already_joined and 'No' or 'Yes') .. ']')

    local ply = player.GetBySteamID64(sid64)
    if not ply or not IsValid(ply) then return end

    if already_joined or Discord.Config.JoinRewards.ShouldNotReward(ply) then
        net.Start('Discord_JoinDiscord')
        net.Send(ply)

        return Discord.Util:PlyChat(ply, Discord.Util:GetLang('JOINED_DISCORD_ALREADY'))
    end

    Discord:Log('Player "' .. ply:Name() .. '" joined your Discord!')
    Discord.Util:PlyChat(ply, Discord.Util:GetLang('JOINED_DISCORD'))
    Discord.Config.JoinRewards.RewardFunc(ply)

    net.Start('Discord_JoinDiscord')
    net.Send(ply)
end, 'joinrewards')