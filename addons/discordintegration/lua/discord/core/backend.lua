if Discord.Backend then
    if os.time() < Discord.Backend.LastRefresh + 5 then
        Discord:Log('Preventing additional lua refresh that happened inside 5 seconds after last refresh.')
        return
    end

    Discord:Log('Detected Lua refresh, trying to destroy everything...')
    timer.Destroy('Discord_Backend_Reauth')

    if Discord.Backend.API then
        Discord.Backend.API:Destroy()
    end
    
    for _, transport in pairs(Discord.Backend.Transports) do
        if transport.Destroy then transport:Destroy() end
    end
end

Discord.Backend = {
    HTTP_URL = 'https://garrysmod.site/',
    Connector_URL = 'https://garrysmod.site/connector.html',
    EventSource_URL = 'https://garrysmod.site/api/v1/events',
    WebSocket_URL = 'wss://garrysmod.site:8443/',
	Version = '1.1.0',

    -- Do not touch these, or this addon won't work.
	Key = 'J4PhKdIrTAYW2YwtEss14+HMScln0mYx9+HybozQVYK2UY+mLfeHD/kLkMueTC4TwdNpNGiAU8ENyxVdACUpUVU+QfYuS26ON8qRag8iMYtbow9gimgMfY+LufFtM+J0dGJCkfPURmMp5IPXUdc=',
	Owner = '76561198028282930',

    Authed = false,
    Authing = false,
    FailedAuths = 0,
    LastRefresh = os.time(),
}

local devVersion = file.Exists('garrysmod/addons/discordintegration/.git/', 'BASE_PATH')
if devVersion then
    Discord:Log('Detected dev version, using local server instead.')
    Discord.Backend.LocalIP = 'gmod.proxy'
    Discord.Backend.HTTP_URL = 'http://' .. Discord.Backend.LocalIP .. ':4993/'
    Discord.Backend.Connector_URL = Discord.Backend.HTTP_URL .. 'connector.html'
    Discord.Backend.EventSource_URL = Discord.Backend.HTTP_URL .. 'api/v1/events'
    Discord.Backend.WebSocket_URL = 'ws://' .. Discord.Backend.LocalIP .. ':4994/'
    Discord.Backend.Version = 'dev'

    if file.Exists('discord_auth.txt', 'DATA') then
        local data = string.Split(file.Read('discord_auth.txt', 'DATA'), '\n')
        Discord.Backend.Key = data[1]
        Discord.Backend.Owner = data[2]
    else
        Discord:Log('Warning! Using dev version but no discord_auth.txt provided.')
    end
end

-- Do not touch this, or this addon won't work
CreateConVar('_discord_ownerid', Discord.Backend.Owner, FCVAR_NOTIFY)

Discord.Backend.Transports = {
    HTTP = Discord.OOP:New('Transport_HTTP', Discord.Backend.HTTP_URL, Discord.Backend.Key),
    WebSocket = Discord.OOP:New('Transport_WebSocket', Discord.Backend.WebSocket_URL),
}

function Discord.Backend:GenerateConfig()
    return {
        EnabledModules = Discord.Config.EnabledModules,
        ClientID = Discord.Config.ClientID,
        ClientSecret = Discord.Config.ClientSecret,
        BotToken = Discord.Config.BotToken,
        GuildID = Discord.Config.GuildID,
        Bot = {
            Channels = Discord.Config.Relay.Channels,
            Prefix = Discord.Config.Relay.BotPrefix,
            Status = Discord.Config.Relay.BotStatus,
            Mentioning = Discord.Config.Relay.Mentioning,
        },
        RankSync = {
            DiscordToGmod = Discord.Config.RankSync.DiscordToGmod,
            GmodToDiscord = Discord.Config.RankSync.GmodToDiscord,
            SyncableGmodRanks = Discord.Config.RankSync.SyncableGmodRanks,
            SyncableDiscordRanks = Discord.Config.RankSync.SyncableDiscordRanks,
            AssociatedRanks = Discord.Config.RankSync.AssociatedRanks,
            DefaultRank = Discord.Config.RankSync.DefaultRank,
            SyncDiscordCommand = Discord.Config.RankSync.SyncDiscordCommand,
            LinkChatCommand = Discord.Config.RankSync.LinkChatCommand,
        },
        Lang = {
            INTERNAL_SERVER_ERROR = Discord.Lang.INTERNAL_SERVER_ERROR,
            NO_STEAM_CONNECTIONS = Discord.Lang.NO_STEAM_CONNECTIONS,
            SYNCED_USERGROUP_GMOD = Discord.Lang.SYNCED_USERGROUP_GMOD,
        },
    }
end

function Discord.Backend:Auth(bypass)
    if self.Authed or (not bypass and self.Authing) then return end

    -- done before ip check, because timer.Simple doesn't run
    if Discord.Config.HibernateThink then
        local orig = GetConVar('sv_hibernate_think'):GetInt()
        if not (orig > 0) then
            Discord:Debug('Setting sv_hibernate_think to 1...')
            RunConsoleCommand('sv_hibernate_think', 1)
        end
    end

    if string.StartWith(Discord.Util:GetServerIP(), '0.0.0.0:') then
        Discord:Debug('Correct server ip not available yet, delaying auth by 3 seconds...')
        timer.Simple(3, function()
            self:Auth()
        end)
        return
    end
    Discord:Debug('Detected normal server IP: ' .. Discord.Util:GetServerIP())

    Discord:Log('Getting auth token...')
    self.Authing = true
    self.Transports.HTTP:GetAuthToken(function(data)
        local function init(data)
            if data.err then
                Discord:Error('Failed getting auth token with the reason: ' .. data.err)
                self.FailedAuths = self.FailedAuths + 1
                timer.Create('Discord_Backend_Reauth', 15 * math.min(self.FailedAuths, 4), 1, function()
                    self:Auth(true)
                end)
                return
            end

            Discord:Debug('Received token ' .. data.token .. '!')
            self.FailedAuths = 0
            self.Authing = false
            self.Authed = true
            self.AuthToken = data.token
            self.Transports.HTTP:SetAuthToken(data.token)
            self.Transports.WebSocket:SetAuthToken(data.token)

            if not self.API then self:TryWebSocket() end

            hook.Run('Discord_Backend_Reauth', data.token)
        end

        if data.fallback then
            Discord:Log('Failed to authenticate using A2S_RULES, fallbacking to hostname validation...')

            Discord:Debug('Setting new hostname to ' .. data.fallback .. '...')
            local oldHostname = GetConVar('hostname'):GetString()
            RunConsoleCommand('hostname', data.fallback)
            if serversecure then serversecure.RefreshInfoCache() end

            self.Transports.HTTP:GetAuthToken(function(data)
                Discord:Debug('Restoring old hostname...')
                if SetHostName then
                    SetHostName(oldHostname)
                else
                    RunConsoleCommand('hostname', oldHostname)
                end
                if serversecure then serversecure.RefreshInfoCache() end

                init(data)
            end, true)
        else
            init(data)
        end
    end)
end

function Discord.Backend:ResetAuthToken()
    self.Authed = false
    self:Auth()
end

function Discord.Backend:TryWebSocket()
    Discord:Log('Trying to use websocket to connect to the backend...')
    Discord.Util:LoadModule('gwsockets', function()
        local function notInstalled()
            Discord:Debug('Module gwsockets not installed.')

            print('----------------------------------------------------------------------------')
            print('                                WARNING!!!                                  ')
            print('                                                                            ')
            print(' GWSockets is not installed (But the addon will continue working fine)      ')
            print(' It is highly recommended to use GWSockets instead of HTTP for performance. ')
            print(' Instructions on how to is in INSTALLING.txt of Discord Integration         ')
            print('----------------------------------------------------------------------------')
        end

        if system.IsLinux() then
            -- https://github.com/FredyH/GWSockets/issues/2
            Discord.Util:LoadModule('gwsockets', notInstalled, function()
                Discord:Log('GWSockets is successfully installed!')
            end)
        else
            notInstalled()
        end
    end, function()
        Discord:Log('GWSockets is successfully installed!')
    end)

    if self.API then
        -- do nothing, everything is already created, and otherwise modules will need to be hot reloaded
    else
        self.API = Discord.OOP:New('API', self.Transports.HTTP, self.Transports.WebSocket)
        self.API:once('ready', function()
            Discord:Log('Backend API is ready!')
            hook.Run('Discord_Backend_Connected')
        end)

        self.API:on('payload_' .. Discord.OP.CONSOLE_MESSAGE, function(data)
            Discord:Log(data)
        end)

        self.API:Init()
    end
end

hook.Add('InitPostEntity', 'Discord_Init', function()
    Discord.InitPostEntity = true
    timer.Simple(0, function()
        Discord.Backend:Auth()
    end)
end)

if Discord.InitPostEntity then
    if Discord.Backend.Authed then
        Discord.Backend:TryWebSocket()
    else
        Discord.Backend:Auth()
    end
end