Discord.Backend.API:on('payload_' .. Discord.OP.RELAY_MESSAGE, function(data)
    if not Discord.Config.Relay.RelayDiscord then return end

    if engine.ActiveGamemode() == 'terrortown' then
        if GetRoundState() == ROUND_ACTIVE then
            if LocalPlayer():Alive() and Discord.Config.Relay.PreventGhosting then return end
        end
    end

    Discord:Chat(Discord.Util:Hex2RGB(data.color), data.username, color_white, ': ', data.content)
end, 'relay')