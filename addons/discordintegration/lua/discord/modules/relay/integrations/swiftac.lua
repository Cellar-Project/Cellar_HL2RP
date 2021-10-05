if not SwiftAC then return end
if not Discord.Config.Relay.SwiftAC then
    Discord:Log('SwiftAC integration disabled, not loading...')
    return
end

if not Discord.Config.Relay.Channels.Admin or Discord.Config.Relay.Channels.Admin == '' then
    Discord:Log('SwiftAC integration couldn\'t be enabled, no admin channel configured.')
    return
end

Discord:Log('Enabling SwiftAC integration...')
hook.Add('SwiftAC.OnPunish', 'Discord', function(plytbl, violations)
    local detections = ''
    for _, name in pairs(violations) do
        local prefix = ''
        if _ > 1 then prefix = ', ' end
        detections = detections .. prefix .. name
    end

    local title = plytbl.Nick .. ' (' .. plytbl.SteamID .. ')'
    if IsValid(plytbl.ent) then
        Discord.SS:Request(plytbl.ent, 70, function(err, url)
            if err then
                Discord.Backend.API:Send(
                    Discord.OOP:New('Message'):SetChannel('Admin'):SetEmbed({
                        color = 0x3498db,
                        description = Discord.Util:GetLang('SWIFTAC_DESCRIPTION_ERROR', {
                            detections = detections,
                            error = err,
                        }),
                        title = title,
                    }):ToAPI()
                )
                return
            end

            Discord.Backend.API:Send(
                Discord.OOP:New('Message'):SetChannel('Admin'):SetEmbed({
                    color = 0x3498db,
                    description = Discord.Util:GetLang('SWIFTAC_DESCRIPTION', {
                        detections = detections,
                        url = url,
                    }),
                    title = title,
                    image = {
                        url = url,
                    },
                }):ToAPI()
            )
        end)
    else
        Discord.Backend.API:Send(
            Discord.OOP:New('Message'):SetChannel('Admin'):SetEmbed({
                color = 0x3498db,
                description = Discord.Util:GetLang('SWIFTAC_DESCRIPTION_ERROR', {
                    detections = detections,
                    error = 'Player isn\'t in the server anymore.',
                }),
                title = title,
            }):ToAPI()
        )
    end
end)