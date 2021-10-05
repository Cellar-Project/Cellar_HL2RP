if not GAS or not GAS.JobWhitelist or not DarkRP then return end
if not Discord.Config.Relay.bWhitelist then
    Discord:Log('bWhitelist integration disabled, not loading...')
    return
end

Discord:Log('Enabling bWhitelist integration...')

local function findJob(name)
    local index = _G[name] and tonumber(_G[name])
    if index and RPExtraTeams[index] then return index end

    for index, job in ipairs(RPExtraTeams) do
        if string.find(string.lower(job.name), string.lower(name), 1, true) then
            return index
        end
    end
end

Discord:RegisterCommand('job', function(data)
    if not Discord.Util.Commands.hasPermission(data.author, 'job') then return Discord.Util.Commands.commandError(data, Discord.Util:GetLang('NO_PERMISSIONS')) end
    if data.argstr == '' then return Discord.Util.Commands.commandError(data, Discord.Util:GetLang('NO_ARGUMENT_PROVIDED')) end

    local args = data.argstr:Split(' ')
    local method = args[1]
    if method ~= 'whitelist' and method ~= 'blacklist' then return Discord.Util.Commands.commandError(data, Discord.Util:GetLang('BWHITELIST_WRONG_METHOD')) end

    local name = args[2]
    if not name then return Discord.Util.Commands.commandError(data, Discord.Util:GetLang('BWHITELIST_NO_PLAYER_NAME')) end

    local target = Discord.Util.Commands.findPlayer(name)
    if not target then return Discord.Util.Commands.commandError(data, Discord.Util:GetLang('PLAYER_COULDNT_BE_FOUND')) end

    local job = args[3]
    if not job then return Discord.Util.Commands.commandError(data, Discord.Util:GetLang('BWHITELIST_NO_JOB_NAME')) end

    job = findJob(job)
    if not job then return Discord.Util.Commands.commandError(data, Discord.Util:GetLang('BWHITELIST_JOB_COULDNT_BE_FOUND')) end

    if method == 'whitelist' then
        if not GAS.JobWhitelist:IsWhitelistEnabled(job) then
            return Discord.Util.Commands.commandError(data, Discord.Util:GetLang('BWHITELIST_WHITELIST_DISABLED'))
        end

        local removed = GAS.JobWhitelist:IsWhitelisted(target, job)
        if removed then
            GAS.JobWhitelist:RemoveFromWhitelist(job, GAS.JobWhitelist.LIST_TYPE_STEAMID, target:SteamID64())
        else
            GAS.JobWhitelist:AddToWhitelist(job, GAS.JobWhitelist.LIST_TYPE_STEAMID, target:SteamID64())
        end

        Discord.Util.Commands.commandEvent(data, Discord.Util:GetLang('BWHITELIST_WHITELIST_' .. (removed and 'REMOVED' or 'ADDED'), {
            job = RPExtraTeams[job].name,
            name = target:Name(),
        }))
    else
        if not GAS.JobWhitelist:IsWhitelistEnabled(job) then
            return Discord.Util.Commands.commandError(data, Discord.Util:GetLang('BWHITELIST_BLACKLIST_DISABLED'))
        end

        local removed = GAS.JobWhitelist:IsBlacklisted(target, job)
        if removed then
            GAS.JobWhitelist:RemoveFromBlacklist(job, GAS.JobWhitelist.LIST_TYPE_STEAMID, target:SteamID64())
        else
            GAS.JobWhitelist:AddToBlacklist(job, GAS.JobWhitelist.LIST_TYPE_STEAMID, target:SteamID64())
        end

        Discord.Util.Commands.commandEvent(data, Discord.Util:GetLang('BWHITELIST_BLACKLIST_' .. (removed and 'REMOVED' or 'ADDED'), {
            job = RPExtraTeams[job].name,
            name = target:Name(),
        }))
    end
end)