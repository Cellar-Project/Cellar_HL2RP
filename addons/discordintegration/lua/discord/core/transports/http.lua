local Transport = {}

function Transport:Constructor(domain, key)
    self.baseurl = domain .. 'api/v1/'
    self.key = key
end

function Transport:_API(payload, queueCb)
    local endpointPrint = (payload.method or 'GET') .. ' /' .. payload.endpoint
    Discord:Debug('Processing payload to ' .. endpointPrint)
    HTTP({
        url = self.baseurl .. payload.endpoint,
        method = payload.method or 'GET',
        parameters = payload.data,
        headers = {
            ['Authorization'] = payload.token and string.Trim('Bearer ' .. payload.token),
        },
        success = function(code, body, headers)
            if code >= 200 and code < 300 then
                local json = util.JSONToTable(body)
                if not json then
                    Discord:Log('Received invalid json on ' .. endpointPrint .. '. Body: ' .. (body and string.sub(body, 0, 100) .. (#body > 100 and '...' or '') or '<EMPTY BODY>'))
                    queueCb(false)
                    return
                end

                if payload.callback then
                    payload.callback(json)
                end

                queueCb(true)
            elseif not string.StartWith(payload.endpoint, '/api/v1/auth') and code == 403 then
                Discord.Backend:ResetAuthToken()
                queueCb(false)
            else
                Discord:Log('Received code ' .. code .. ' for request to ' .. endpointPrint .. ' (' .. (body and string.sub(body, 0, 100) .. (#body > 100 and '...' or '') or '<EMPTY BODY>') .. ')')
                queueCb(code == 400) -- We don't want to retry bad requests
            end
        end,
        failed = function(err)
            Discord:Log('Failed request to ' .. endpointPrint .. ' with the error: ' .. err)
            queueCb(false)
        end,
    })
end

function Transport:GetAuthToken(callback, fallback)
    self:API({
        endpoint = fallback and 'auth/fallback' or 'auth',
        data = {
            ['ServerIP'] = Discord.Backend.Version == 'dev' and Discord.Backend.LocalIP .. ':27020' or Discord.Util:GetServerIP(),
            ['License'] = Discord.Backend.Owner,
            ['Version'] = Discord.Backend.Version,
            ['Config'] = util.TableToJSON(Discord.Backend:GenerateConfig()),
        },
        token = self.key,
        method = 'POST',
        callback = callback,
    }, true)
end

function Transport:GetLatestError(callback)
    self:_API({
        endpoint = 'error',
        method = 'GET',
        data = {
            error_ip = string.Replace(Discord.Util:GetServerIP(), ':', '_'),
        },
        callback = callback,
    }, function(success)
        if not success then
            callback({})
        end
    end)
end

function Transport:StartPolling(parseFunc)
    self._parseFunc = parseFunc
    self._keepPolling = true
    self:Poll()
end

function Transport:Poll()
    if self._polling then return end

    self._polling = true
    self:_API({ -- skip the internal queue, because otherwise it'll take ages to get processed
        endpoint = 'poll',
        token = self._authtoken,
        method = 'GET',
        callback = function(json)
            if self._parseFunc then self._parseFunc(json) end
        end,
    }, function(success)
        self._polling = false

        if success then
            if self._keepPolling then self:Poll() end
        else
            timer.Simple(15, function() -- implement something better?
                if self._keepPolling then self:Poll() end
            end)
        end
    end)
end

function Transport:Destroy()
    self:_destroy()
    self._keepPolling = false
end

Discord.OOP:Register('Transport_HTTP', Transport, 'BaseTransport')