local Connector = {}

function Connector:Init()
    self.frame = vgui.Create('DFrame')
    self.frame:SetSize(0, 0)

    self.html = vgui.Create('DHTML', frame)

    self.method = nil
    self.qs = nil
    self.ready = false
    self.connected = false
    self.queue = {}

    self.html.OnDocumentReady = function()
        timer.Simple(0, function()
            self.ready = true
            if self.connectLater then
                self:Connect()
                self.connectLater = nil
            end

            self:emit('ready')
        end)
    end

    self.html:AddFunction('gmod', 'setMethod', function(method)
        self.method = method
    end)

    self.html:AddFunction('gmod', 'open', function()
        self.connected = true

        while(#self.queue > 0) do
            self:Send(table.remove(self.queue, 1))
        end

        self:emit('open')
    end)

    self.html:AddFunction('gmod', 'message', function(data)
        self:emit('message', data)
    end)

    self.html:AddFunction('gmod', 'error', function(err)
        self:emit('error', err);
    end)

    self.html:AddFunction('gmod', 'close', function()
        self.connected = false
        self:emit('close')
    end)

    self.html:OpenURL(Discord.Backend.Connector_URL)
    self.html:SetAllowLua(true)
end

function Connector:Connect(key)
    if key then
        self.qs = '?access_token=' .. key .. '&type=client&sid64=' .. LocalPlayer():SteamID64()
    end

    if self.ready and self.qs then
        local url
        if self.method == 'ws' then
            url = Discord.Backend.WebSocket_URL .. self.qs
        elseif self.method == 'es' then
            url = Discord.Backend.EventSource_URL .. self.qs
        else
            self:emit('error', 'Unable to get a valid method to use for communication...?')
            return
        end

        self.html:Call('connect("' .. url .. '");')
    else
        self.connectLater = true
    end
end

function Connector:Send(payload)
    if self.connected and self.method == 'ws' then
        self.html:Call("send('" .. payload .. "');")
    elseif self.method == 'es' then
        HTTP({
            url = Discord.Backend.HTTP_URL .. 'api/v1/action' .. self.qs,
            method = 'POST',
            parameters = {
                payload = payload,
            },
            success = function(code, body, headers)
                if code < 200 or code >= 300 then
                    Discord:Log('Failed request through connector - HTTP '.. code .. ': ' .. body)
                end
            end,
            failed = function(err)
                Discord:Log('Failed request through connector with the error: ' .. err)
            end,
        })
    else
        table.insert(self.queue, data)
    end
end

function Connector:Disconnect()
    if not self.ready then return end

    self.html:Call('disconnect();');
end

function Connector:Destroy()
    self:destroy()
    
    if self.frame then
        self:Disconnect()
        self.frame:Close()
        self.frame = nil
    end
end

Discord.OOP:Register('Connector', Connector, 'EventEmitter')