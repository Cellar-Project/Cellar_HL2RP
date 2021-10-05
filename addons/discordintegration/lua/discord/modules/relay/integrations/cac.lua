if not CAC then return end
if not Discord.Config.Relay.CAC then
    Discord:Log('CAC integration disabled, not loading...')
    return
end

if not Discord.Config.Relay.Channels.Admin or Discord.Config.Relay.Channels.Admin == '' then
    Discord:Log('CAC integration couldn\'t be enabled, no admin channel configured.')
    return
end

Discord:Log('Enabling CAC integration...')

local function hookPly(ply)
    CAC.LivePlayerSessionManager:GetLivePlayerSession(ply):GetPlayerSession():AddEventListener('DetectionAdded', 'Discord', function(detection)
        local detections = detection.Detections
        local tbl = {}
        for name, _ in pairs(detections) do
            local new = ''
            for __, char in pairs(string.Explode('', name)) do
                if string.upper(char) == char then
                    new = new .. ' ' .. char
                else
                    new = new .. char
                end
            end
            table.insert(tbl, new)
        end

        local detections = ''
        for _, name in pairs(tbl) do
            local prefix = ''
            if _ > 1 then prefix = ', ' end
            detections = detections .. prefix .. name
        end
        local footer = ply:Name() .. ' (' .. ply:SteamID() .. ')'

        Discord.SS:Request(ply, 70, function(err, url)
            if err then
                Discord.Backend.API:Send(
                    Discord.OOP:New('Message'):SetChannel('Admin'):SetEmbed({
                        color = 0x3498db,
                        description = Discord.Util:GetLang('CAC_DESCRIPTION_ERROR', {
                            detections = detections,
                            error = err,
                        }),
                        footer = footer,
                    }):ToAPI()
                )
                return
            end

            Discord.Backend.API:Send(
                Discord.OOP:New('Message'):SetChannel('Admin'):SetEmbed({
                    color = 0x3498db,
                    description = Discord.Util:GetLang('CAC_DESCRIPTION', {
                        detections = detections,
                        url = url,
                    }),
                    footer = footer,
                    image = {
                        url = url,
                    },
                }):ToAPI()
            )
        end)
    end)
end

for _, ply in ipairs(player.GetAll()) do
    hookPly(ply)
end

hook.Add('PlayerInitialSpawn', 'Discord_Hook_CAC', function(ply)
    timer.Simple(0, function()
        hookPly(ply)
    end)
end)