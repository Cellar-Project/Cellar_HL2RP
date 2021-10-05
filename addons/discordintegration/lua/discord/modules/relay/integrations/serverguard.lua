if not serverguard then return end
if not Discord.Config.Relay.SGLogging then
    Discord:Log('ServerGuard integration disabled, not loading...')
    return
end

if not Discord.Config.Relay.Channels.Admin or Discord.Config.Relay.Channels.Admin == '' then
    Discord:Log('ServerGuard integration couldn\'t be enabled, no admin channel configured.')
    return
end

Discord:Log('Enabling ServerGuard integration...')
Discord.SG_log = Discord.SG_log or serverguard.plugin.GetList().logs.Log
serverguard.plugin.GetList().logs.Log = function(...)
    local str = select(2, ...)
    if str then
        do
            if #Discord.Config.Relay.SGWhitelist > 0 then
                local allowed = false
                for _, good in ipairs(Discord.Config.Relay.SGWhitelist) do
                    if string.find(str, good) then allowed = true break end
                end

                if not allowed then return end
            else
                for _, bad in ipairs(Discord.Config.Relay.SGBlacklist) do
                    if string.find(str, bad) then return end
                end
            end

            Discord.Backend.API:Send(
                Discord.OOP:New('Message'):SetChannel('Admin'):SetEmbed({
                    color = 0x00B4B4,
                    title = Discord.Util:GetLang('SG_TITLE'),
                    description = str,
                }):ToAPI()
            )
        end
    end

    return Discord.SG_log(...)
end