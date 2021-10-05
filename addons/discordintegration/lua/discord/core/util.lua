Discord.Util = {}

function Discord.Util:GetModuleSuffix()
    local arch = string.sub(jit.arch, 2)
    if arch == '86' then
        arch = '32'
    end

    if system.IsWindows() then
        return 'win' .. arch
    end

    return arch == '32' and 'linux' or ('linux' .. arch)
end

function Discord.Util:LoadModule(name, fail, success)
    local filename = 'gm' .. (SERVER and 'sv' or 'cl') .. '_' .. name .. '_' .. Discord.Util:GetModuleSuffix() .. '.dll'

    if file.Exists('garrysmod/lua/bin/' .. filename, 'BASE_PATH') then
        xpcall(function()
            require(name)
            if success then success() end
        end, fail)
        return
    end

    fail()
end

function Discord.Util:IsPrivateSubnet(ip)
    for _, prefix in ipairs({'0.0.0.0', '127.0.0.1', 'localhost', '192.168.', '10.', '172.16.'}) do
        if string.StartWith(ip, prefix) then return true end
    end

    return false
end

function Discord.Util:GetServerIP()
    local gmodip = game.GetIPAddress()
    if SERVER then
        local ipconvar = GetConVar('ip'):GetString()
        local hostport = GetConVarNumber('hostport')
        if not Discord.Util:IsPrivateSubnet(ipconvar) then
            return ipconvar .. ':' .. hostport
        end

        local hostip = GetConVarNumber('hostip')
        local ip = {}
        ip[1] = bit.rshift(bit.band(hostip, 0xFF000000), 24)
        ip[2] = bit.rshift(bit.band(hostip, 0x00FF0000), 16)
        ip[3] = bit.rshift(bit.band(hostip, 0x0000FF00), 8)
        ip[4] = bit.band(hostip, 0x000000FF)

        local serverip = table.concat(ip, '.')
        if serverip ~= gmodip then
            return gmodip
        end

        return serverip .. ':' .. hostport
    else
        return gmodip
    end
end

function Discord.Util:Format(str, formatters)
    local defFormatters = { -- All of these will change at some point, so declare them here instead
        server_ip = Discord.Util:GetServerIP(),
        join_url = 'steam://connect/' .. Discord.Util:GetServerIP(),
        hostname = GetHostName(),
        map = game.GetMap(),
        gamemode = gmod.GetGamemode().Name,
    }

    for _, val in pairs(formatters and table.Merge(defFormatters, formatters) or defFormatters) do
        str = string.Replace(str, '<' .. _ .. '>', val)
    end
    
    return str
end

function Discord.Util:GetLang(str, formatters)
    return Discord.Util:Format(Discord.Lang and Discord.Lang[str] or 'UNKNOWN_LANG_STRING - ' .. str, formatters)
end

function Discord.Util:Hex2RGB(hex)
    hex = hex:gsub('#', '')
    return Color(tonumber('0x' .. hex:sub(1, 2)) or 0, tonumber('0x' .. hex:sub(3, 4)) or 0, tonumber('0x' .. hex:sub(5, 6)) or 0)
end

if SERVER then
    util.AddNetworkString('Discord_Chat')

    function Discord.Util:PlyChat(ply, msg)
        net.Start('Discord_Chat')
            net.WriteString(msg)
        net.Send(ply)
    end
end

if CLIENT then
    function Discord:Chat(...)
        chat.AddText(Color(114, 137, 255), '[Discord] ', Color(255, 255, 255), ...)
    end

    net.Receive('Discord_Chat', function(len, ply)
        Discord:Chat(net.ReadString())
    end)
end