local Message = {}

function Message:SetChannel(channel)
    if not Discord.Config.Relay.Channels[channel] then return Error('Invalid channel name (not in Discord.Config.Relay.Channels)') end
    self.channel = channel
    return self
end

function Message:SetRaw(raw)
    self.raw = raw
    return self
end

function Message:SetMessage(message)
    self.message = message
    return self
end

function Message:SetEmbed(embed)
    self.embed = embed
    return self
end

function Message:ToAPI()
    return {
        op = Discord.OP.MESSAGE,
        d = {
            channel = self.channel,
            message = self.raw or {
                content = self.message,
                embed = self.embed,
            },
        }
    }
end

Discord.OOP:Register('Message', Message)