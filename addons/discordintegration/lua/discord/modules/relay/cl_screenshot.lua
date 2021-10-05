local render_Capture = render.Capture

local cache = nil
local latestQuality = 70
local picFormat = 'jpeg'
local function createCache(quality)
    hook.Add('PostRender', 'Discord_Screenshot', function()
        hook.Remove('PostRender', 'Discord_Screenshot')
        cache = render_Capture({
            format = picFormat,
            quality = quality,
            h = ScrH(),
            w = ScrW(),
            x = 0,
            y = 0
        })
        cache = util.Base64Encode(cache)
    end)
end

local function uploadPic(url, key)
    if not cache then createCache(latestQuality or 70) timer.Simple(0.01, function() uploadPic(url, key) end) return end
    local request = {
        method = 'post',
        url = url,
        parameters = {['picdata'] = cache},
        headers = {['Authorization'] = 'Bearer ' .. key},
        failed = function(err) end,
        success = function(code, body, headers)
            body = util.JSONToTable(body)
            if body and body.status == 'success' then
                net.Start('Discord_Screenshot_Upload')
                net.SendToServer()
            end
        end
    }
    HTTP(request)
    cache = nil
end

net.Receive('Discord_Screenshot_Cache', function(len)
    local quality = net.ReadInt(16)
    latestQuality = quality
    createCache(quality)
end)

net.Receive('Discord_Screenshot_Upload', function(len)
    uploadPic(net.ReadString(), net.ReadString())
end)