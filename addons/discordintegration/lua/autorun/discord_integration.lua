if SERVER and Discord and (type(Discord) ~= 'table' or not Discord.Integration) then
    print('--------------------------------------------------------------------------')
    print('                                WARNING!!!                                ')
    print('                                                                          ')
    print('       Possible collision with Discord Integration and another addon.     ')
    print('       Expect things being possibly broken.                               ')
    print('       Cause: Global variable Discord already in use.                     ')
    print('--------------------------------------------------------------------------')
end

file.CreateDir('discord_integration')

Discord = type(Discord) == 'table' and Discord or {}
Discord.Integration = true
Discord.Modules = {}

function Discord:Log(...)
    MsgC(Color(255, 0, 130), 'Discord -> ', color_white, ..., '\n')
end

function Discord:Error(...)
    MsgC(Color(255, 0, 0), 'Discord Error -> ', color_white, ..., '\n')
end

local val = file.Exists('discord_integration/debug.txt', 'DATA') and tonumber(file.Read('discord_integration/debug.txt', 'DATA')) or 0 -- Because FCVAR_ARCHIVE is shit on server
local discord_debug = (SERVER and CreateConVar or CreateClientConVar)('discord_debug', val, FCVAR_ARCHIVE, 'Enable debug logs for Discord Integration?')
cvars.AddChangeCallback('discord_debug', function(convar, old, new)
    if tonumber(new) then
        file.Write('discord_integration/debug.txt', new)
    end
end, 'save_val')
function Discord:Debug(...)
    if not (discord_debug:GetInt() > 0) then return end
    MsgC(Color(255, 130, 130), 'Discord Debug -> ', color_white, ..., '\n')
end

function Discord:LoadFiles(prefix, files, preload, skipPreload)
    for _, data in ipairs(files) do
        local realm = data[1]
        local filename = data[2]

        if realm == 'sv' and not SERVER then continue end
        Discord:Debug('Loading ' .. filename .. ' in the realm ' .. realm .. '...')

        if SERVER then
            if realm == 'sh' or realm == 'cl' then
                if not skipPreload then AddCSLuaFile('discord/' .. prefix .. filename) end
            elseif realm == 'sv' then
                include('discord/' .. prefix .. filename)
            end
        else
            if realm == 'cl' then
                include('discord/' .. prefix .. filename)
            end
        end

        if not preload and realm == 'sh' then
            include('discord/' .. prefix .. filename)
        end
    end
end

local function getRealmOnly(files, realm)
    local res = {}

    for _, data in ipairs(files) do
        if data[1] == realm then table.insert(res, data) end
    end

    return res
end

function Discord:PreloadModules()
    Discord:Debug('Preloading modules...')

    local _, modules = file.Find('discord/modules/*', 'LUA')
    for _, module in ipairs(modules) do
        Discord:Debug('Loading info for the module "' .. module .. '"...')

        local path = 'discord/modules/' .. module
        local exists = function(filename) return file.Exists(path .. '/' .. filename, 'LUA') end
        if not exists('sh_module.lua') then
            Discord:Debug('Skipping preloading the module "' .. module .. '" because sh_module.lua doesn\'t exist for it.')
            continue
        end

        include(path .. '/sh_module.lua')

        if SERVER and not Discord.Config.EnabledModules[Discord.MODULE.DisplayName] then
            Discord:Debug('Skipping preloading the module "' .. Discord.MODULE.DisplayName .. '" because it\'s disabled.')
            continue
        end

        Discord.MODULE._filename = module
        Discord.Modules[Discord.MODULE.DisplayName] = Discord.MODULE

        if SERVER then
            if Discord.MODULE.Dependencies then
                Discord:LoadFiles('modules/' .. module .. '/', getRealmOnly(Discord.MODULE.Dependencies, 'sh'), true)
                Discord:LoadFiles('modules/' .. module .. '/', getRealmOnly(Discord.MODULE.Dependencies, 'cl'), true)
            end

            AddCSLuaFile(path .. '/sh_module.lua')
            if exists('cl_module.lua') then AddCSLuaFile(path .. '/cl_module.lua') end

            if Discord.MODULE.PostLoad then
                Discord:LoadFiles('modules/' .. module .. '/', getRealmOnly(Discord.MODULE.PostLoad, 'sh'), true)
                Discord:LoadFiles('modules/' .. module .. '/', getRealmOnly(Discord.MODULE.PostLoad, 'cl'), true)
            end
        end

        Discord:Debug('Preloaded the module "' .. Discord.MODULE.DisplayName .. '"')
    end

    Discord.MODULE = nil
    Discord:Debug('Finished preloading!')
end

function Discord:LoadModules()
    Discord:Log('Loading modules...')

    for DisplayName, MODULE in pairs(Discord.Modules) do
        Discord:Debug('Loading the module "' .. DisplayName .. '"...')

        if MODULE.Dependencies then
            Discord:LoadFiles('modules/' .. MODULE._filename .. '/', MODULE.Dependencies, nil, true)
        end

        local path = 'discord/modules/' .. MODULE._filename
        local exists = function(filename) return file.Exists(path .. '/' .. filename, 'LUA') end
        if SERVER then
            if exists('sv_module.lua') then include(path .. '/sv_module.lua') end
        else
            if exists('cl_module.lua') then include(path .. '/cl_module.lua') end
        end

        if MODULE.PostLoad then
            Discord:LoadFiles('modules/' .. MODULE._filename .. '/', MODULE.PostLoad, nil, true)
        end

        Discord:Log('Loaded the module "' .. DisplayName .. '"')
    end

    Discord:Log('Finished loading.')
end
hook.Add('Discord_Backend_Connected', 'LoadModules', Discord.LoadModules)

function Discord:Load()
    Discord:Log('Loading...')

    local _, modules = file.Find('discord/modules/*', 'LUA')
    local none = true
    if SERVER then
        for module, enabled in pairs(Discord.Config.EnabledModules) do
            if enabled then
                none = false
                break
            end
        end
    else
        if #modules > 0 then
            none = false
        end
    end

    if none then
        Discord:Log('Warning! No modules are enabled, and this addon will be pointless. Aborting loading.')
        return
    end

    Discord:Log('Loading core files...')
    local core = {
        {'sh', 'oop.lua'},
        {'sh', 'classes/eventemitter.lua'},
        {'sv', 'classes/api.lua'},
        {'cl', 'classes/cl_connector.lua'},
        {'cl', 'classes/cl_api.lua'},
        {'cl', 'classes/rpc.lua'},

        {'sv', 'transports/basetransport.lua'},
        {'sv', 'transports/http.lua'},
        {'sv', 'transports/websocket.lua'},

        {'sh', 'util.lua'},

        {'sh', 'api_op.lua'},
        {'sv', 'backend_client.lua'},
        {'sv', 'backend.lua'},

        {'cl', 'cl_backend.lua'},
    }
    Discord:LoadFiles('core/', core)
    Discord:PreloadModules()

    Discord:Log('Finished loading core, waiting for backend connection to load modules...')
end

if SERVER then
    include('discord_config.lua')
    AddCSLuaFile('discord_lang.lua')

    if not Discord.Config then
        RunConsoleCommand('sv_hibernate_think', 1)
        timer.Create('Discord_Config_Error', 15, 0, function()
            Discord:Error('Config failed to load, this addon WON\'T work until the following error is fixed:')
            include('discord_config.lua')
        end)
        return
    end
end

include('discord_lang.lua')

if SERVER and not Discord.Lang then
    RunConsoleCommand('sv_hibernate_think', 1)
    timer.Create('Discord_Language_Error', 15, 0, function()
        Discord:Error('Language file failed to load, this addon won\'t work PROPERLY until the following error is fixed:')
        include('discord_lang.lua')
    end)
end

Discord:Load()