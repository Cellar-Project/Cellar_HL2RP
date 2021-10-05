local API = {}

function API:Constructor(http, ws)
    self._http = http
    self._ws = ws
    self._ready = false
    self._method = GWSockets and 'ws' or 'http'

    self.nonce = file.Exists('discord_integration/nonce.txt', 'DATA') and tonumber(file.Read('discord_integration/nonce.txt', 'DATA')) or 0
end

function API:Init()
    if self._method == 'ws' then
        self._connectAttempts = 0

        self._ws:on('connected', function()
            timer.Destroy(tostring(self)..'_Reconnect')
            self._connectAttempts = 0

            Discord:Log('Connected to the Backend API!')
            self:emit('connected')
        end)

        self._ws:once('connected', function()
            self._ready = true

            self:emit('ready')
        end)

        self._ws:on('disconnected', function()
            Discord:Log('WebSocket disconnected.')
            if not self._ws._reconnect then
                Discord:Debug('Aborting automatic reconnect.')
                return
            end
            
            self._connectAttempts = self._connectAttempts + 1
            timer.Create(tostring(self)..'_Reconnect', 15 * math.min(self._connectAttempts, 4), 1, function()
                if self._ws:IsConnected() then
                    Discord:Debug('WebSocket is already connected, aborting automatic reconnect.')
                    return
                end

                Discord:Log('Reconnecting with WebSocket...')
                self._ws:Reconnect()
            end)
        end)

        self._ws:on('message', function(msg)
            self:ParsePayload(msg)
        end)

        self._ws:on('error', function(err)
            if err == 'Connection failed: WebSocket upgrade handshake failed' then
                Discord:Log('Failed handshake with the WebSocket Server, retrieving error...')
                self._http:GetLatestError(function(data)
                    if data.err then
                        if string.StartWith(data.err, '403 - Unauthorized') then
                            Discord:Error('Handshake failed because of invalid auth token, triggering reauthentication...')
                            Discord.Backend:ResetAuthToken()
                        else
                            Discord:Error('Handshake failed with the error: ' .. data.err)
                        end
                    else
                        Discord:Log('Error couldn\'t be retrieved.')
                    end
                end)
            else
                Discord:Log('WebSocket errored: ' .. err)
            end
        end)

        self._ws:Connect()
    elseif self._method == 'http' then
        self._ready = true
        self:emit('ready')

        timer.Simple(1, function() -- Let modules load first
            self._http:StartPolling(function(res)
                self:ParsePayload(res)
            end)
        end)
    end
end

function API:ParsePayload(msg)
    local json
    if type(msg) == 'string' then
        json = util.JSONToTable(msg)
    else
        json = msg
    end
    if not json or type(json) ~= 'table' then return Discord:Log('Invalid JSON received: ' .. msg) end
    if not json.op or not json.d then return end

    if json.op == Discord.OP.PING then
        self:Send({
            op = Discord.OP.PONG,
            d = json.d,
        })
        return
    elseif json.op == Discord.OP.ERROR then
        Discord:Error('Backend: ' .. json.d)
    end

    Discord:Debug('Received payload: ' .. util.TableToJSON(json))
    self:emit('payload', json)
    self:emit('payload_' .. json.op, json.d)
end

function API:Send(payload)
    if type(payload) ~= 'table' then error('Payload isn\'t a table.') end
    if not payload.d or not payload.op then error('Invalid format for a payload') end

    if self._method == 'ws' then
        self._ws:API(payload)
    elseif self._method == 'http' then
        self._http:API({
            endpoint = 'payload',
            data = {
                payload = util.TableToJSON(payload),
            },
            token = self._http._authtoken,
            method = 'POST',
        })
    end
end

function API:GetNonce()
    self.nonce = self.nonce + 1
    file.Write('discord_integration/nonce.txt', self.nonce)
    return self.nonce
end

function API:Destroy()
    timer.Destroy(tostring(self)..'_Reconnect')
end

Discord.OOP:Register('API', API, 'EventEmitter')