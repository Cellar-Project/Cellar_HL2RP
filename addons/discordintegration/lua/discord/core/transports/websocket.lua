local Transport = {}

function Transport:Constructor(baseurl)
    self.baseurl = baseurl

    self._connected = false
    self._reconnect = true
end

function Transport:Connect()
    if self._ws then
        self._reconnect = false
        self._ws:close()
    end

    self._ws = GWSockets.createWebSocket(self.baseurl .. 'server/' .. self._authtoken .. '/' .. string.Replace(Discord.Util:GetServerIP(), ':', '_')) -- fallback method for data in url, gwsockets broke headers :/
    self._ws:setHeader('Authorization', self._authtoken) -- gwsockets hates spaces in value for w/e reason
    self._ws:setHeader('type', 'server')
    self._ws:setHeader('error_ip', string.Replace(Discord.Util:GetServerIP(), ':', '_'))

    local this = self
    function self._ws:onMessage(msg) this:onMessage(msg) end
    function self._ws:onError(err) this:onError(err) end
    function self._ws:onConnected() this:onConnected() end
    function self._ws:onDisconnected() this:onDisconnected() end

    self._ws:open()
end

function Transport:onMessage(payload)
    self:emit('message', payload)
end

function Transport:onError(err)
    self:emit('error', err)
end

function Transport:onConnected()
    self._connected = true
    self._reconnect = true

    self:emit('connected')
end

function Transport:onDisconnected()
    self._connected = false

    self:emit('disconnected')
end

function Transport:IsConnected()
    return self._connected
end

function Transport:Reconnect()
    self._ws:open()
end

function Transport:API(payload) -- we have internal "queue" in GWSockets
    self._ws:write(util.TableToJSON(payload))
end

function Transport:Destroy()
    self:_destroy()

    if self._ws then
        self._reconnect = false
        self._ws:close()
    end
end

Discord.OOP:Register('Transport_WebSocket', Transport, 'BaseTransport')