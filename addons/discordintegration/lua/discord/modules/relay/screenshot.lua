Discord.SS = Discord.SS or {
    Requests = {}
}

util.AddNetworkString('Discord_Screenshot_Cache')
util.AddNetworkString('Discord_Screenshot_Upload')

function Discord.SS:Request(ply, quality, callback)
	if not ply or not IsValid(ply) or not type(ply) == 'player' then return callback(Discord.Util:GetLang('INVALID_PLAYER')) end
    if Discord.SS.Requests[ply:SteamID64()] then return callback(Discord.Util:GetLang('ALREADY_BEING_SCREENSHOTTED')) end
	Discord:Debug('Screenshotting ' .. ply:Name() .. '...')
	quality = quality or 70
	
	net.Start('Discord_Screenshot_Cache')
		net.WriteInt(quality, 16)
	net.Send(ply)
	
    Discord.SS.Requests[ply:SteamID64()] = {
        callback = callback,
        sentAt = CurTime(),
    }

    Discord.Backend.API:Send({
        op = Discord.OP.SCREENSHOT,
        d = ply:SteamID64(),
    })
end

Discord.Backend.API:on('payload_' .. Discord.OP.SCREENSHOT, function(data)
    local sid64 = data.sid64
    if not Discord.SS.Requests[sid64] then return end

    local ply = player.GetBySteamID64(sid64)
    if not ply or not IsValid(ply) then
        Discord.SS.Requests[sid64].callback('Player left')
        Discord.SS.Requests[sid64] = nil
        return
    end

    Discord:Debug('Received screenshot key for ' .. ply:Name() .. '!')

    Discord.SS.Requests[sid64].url = data.url .. '/view/' .. data.key

    net.Start('Discord_Screenshot_Upload')
        net.WriteString(data.url .. '/api/v1/ss')
        net.WriteString(data.key)
    net.Send(ply)
end, 'screenshot')

hook.Add('PlayerDisconnected', 'Discord_Screenshot', function(ply)
    Discord.SS.Requests[ply:SteamID64()] = nil
end)

net.Receive('Discord_Screenshot_Upload', function(len, ply)
    local sid64 = ply:SteamID64()
	if not Discord.SS.Requests[sid64] then return end

	Discord:Debug('Received screenshot confirmation from ' .. ply:Name() .. ', took ' .. math.Round(CurTime() - Discord.SS.Requests[sid64].sentAt, 2) .. ' seconds.')

	if Discord.SS.Requests[sid64].callback then
        Discord.SS.Requests[sid64].callback(nil, Discord.SS.Requests[sid64].url)
    else
        Discord:Log('Screenshot for ' .. ply:Name() .. ': ' .. Discord.SS.Requests[sid64].url)
    end
    Discord.SS.Requests[sid64] = nil
end)