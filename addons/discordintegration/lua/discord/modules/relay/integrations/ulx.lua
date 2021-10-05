if not ULib or not ulx then return end
if not Discord.Config.Relay.ULXLogging then
    Discord:Log('ULX integration disabled, not loading...')
    return
end

if not Discord.Config.Relay.Channels.Admin or Discord.Config.Relay.Channels.Admin == '' then
    Discord:Log('ULX integration couldn\'t be enabled, no admin channel configured.')
    return
end

Discord:Log('Enabling ULX integration...')
game.ConsoleCommand('ulx logFile 1\n')
Discord.ULX_logString = Discord.ULX_logString or ulx.logString
ulx.logString = function(...)
    local str = select(1, ...)
    if str then
        do
            if #Discord.Config.Relay.ULXWhitelist > 0 then
                local allowed = false
                for _, good in ipairs(Discord.Config.Relay.ULXWhitelist) do
                    if string.find(str, good) then allowed = true break end
                end

                if not allowed then return end
            else
                for _, bad in ipairs(Discord.Config.Relay.ULXBlacklist) do
                    if string.find(str, bad) then return end
                end
            end

            Discord.Backend.API:Send(
                Discord.OOP:New('Message'):SetChannel('Admin'):SetEmbed({
                    color = 0x00B4B4,
                    title = Discord.Util:GetLang('ULX_TITLE'),
                    description = str,
                }):ToAPI()
            )
        end
    end

    return Discord.ULX_logString(...)
end