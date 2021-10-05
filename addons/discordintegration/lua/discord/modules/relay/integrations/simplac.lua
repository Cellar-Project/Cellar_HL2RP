if not Simplac then return end
if not Discord.Config.Relay.SimpLAC then
    Discord:Log('SimpLAC integration disabled, not loading...')
    return
end

if not Discord.Config.Relay.Channels.Admin or Discord.Config.Relay.Channels.Admin == '' then
    Discord:Log('SimpLAC integration couldn\'t be enabled, no admin channel configured.')
    return
end

Discord:Log('Enabling SimpLAC integration...')
hook.Add('Simplac.PlayerViolation', 'Discord', function(ply, sid64, violation)
    local title = ply:Name() .. ' (' .. ply:SteamID() .. ')'
    Discord.SS:Request(ply, 70, function(err, url)
        if err then
            Discord.Backend.API:Send(
                Discord.OOP:New('Message'):SetChannel('Admin'):SetEmbed({
                    color = 0x3498db,
                    description = Discord.Util:GetLang('SIMPLAC_DESCRIPTION_ERROR', {
                        detections = violation,
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
                description = Discord.Util:GetLang('SIMPLAC_DESCRIPTION', {
                    detections = violation,
                    url = url,
                }),
                title = title,
                image = {
                    url = url,
                },
            }):ToAPI()
        )
    end)
end)