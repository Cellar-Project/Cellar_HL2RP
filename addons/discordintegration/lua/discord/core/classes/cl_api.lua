local API = {}

function API:Constructor()
    self._connector = Discord.OOP:New('Connector')
    self._connector:Init()

    self._attempts = 0
    self._connected = false
end

function API:Init()
    self._connector:on('open', function()
        Discord:Log('Connected to Backend!')

        self._attempts = 0
        self._connected = true

        self:emit('open')
    end)

    self._connector:on('message', function(message)
        local json = util.JSONToTable(message)
        if not json then return Discord:Log('Invalid JSON received: ' .. message) end

        if json.op == Discord.OP.PING then
            if self._connector.method == 'es' then return end

            self:Send({
                op = Discord.OP.PONG,
                d = json.d,
            })
            return
        elseif json.op == Discord.OP.ERROR then
            Discord:Chat(Discord.Util:GetLang(json.d))
            Discord:Error(Discord.Util:GetLang(json.d))
            return
        elseif json.op == Discord.OP.CONSOLE_MESSAGE then
            Discord:Log(json.d)
            return
        elseif json.op == Discord.OP.CHAT_MESSAGE then
            Discord:Chat(Discord.Util:GetLang(json.d.id, json.d.data))
            return
        end

        self:emit('payload', json)
        self:emit('payload_' .. json.op, json.d)
    end)

    self._connector:on('close', function()
        if self._connected then Discord:Log('Disconnected from backend.') end
        self._connected = false

        if self._attempts <= 3 then
            timer.Create(tostring(self), 10 * math.min(self._attempts, 6), 1, function()
                if self._attempts <= 3 then
                    self:Connect()
                else
                    self._attempts = 1
                    self:emit('request_key')
                end
            end)
        else
            timer.Destroy(tostring(self))
            
            self._attempts = 1
            self:emit('request_key')
        end
    end)

    self._connector:on('error', function(err)
        local errmsg = type(err) == "table" and util.TableToJSON(err) or (err or '<NO ERROR RETURNED>')
        Discord:Error('Connector errored: ' .. errmsg)
    end)
end

function API:Connect()
    self._attempts = self._attempts + 1
    self._connector:Disconnect()
    self._connector:Connect(Discord.Backend.Key)
end

function API:Send(payload)
    self._connector:Send(util.TableToJSON(payload))
end

function API:Destroy()
    self._connector:Destroy()

    timer.Destroy(tostring(self))
end

Discord.OOP:Register('API', API, 'EventEmitter')