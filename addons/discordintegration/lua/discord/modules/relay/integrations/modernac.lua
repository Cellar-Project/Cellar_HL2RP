if not (hook.GetTable().PlayerAuthed and hook.GetTable().PlayerAuthed.check_player_mac) then return end
if not Discord.Config.Relay.ModernAC then
    Discord:Log('ModernAC integration disabled, not loading...')
    return
end

if not Discord.Config.Relay.Channels.Admin or Discord.Config.Relay.Channels.Admin == '' then
    Discord:Log('ModernAC integration couldn\'t be enabled, no admin channel configured.')
    return
end

Discord:Log('Enabling ModernAC integration...')
local function a(ply, reason)
    local title = ply:Name() .. ' (' .. ply:SteamID() .. ')'
    Discord.SS:Request(ply, 70, function(err, url)
        if err then
            Discord.Backend.API:Send(
                Discord.OOP:New('Message'):SetChannel('Admin'):SetEmbed({
                    color = 0x3498db,
                    description = Discord.Util:GetLang('MODERNAC_DESCRIPTION_ERROR', {
                        reason = reason,
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
                    reason = reason,
                    url = url,
                }),
                title = title,
                image = {
                    url = url,
                },
            }):ToAPI()
        )
    end)
end
hook.Add('modern_banned_player', 'Discord', a)
hook.Add('modern_kicked_player', 'Discord', a)