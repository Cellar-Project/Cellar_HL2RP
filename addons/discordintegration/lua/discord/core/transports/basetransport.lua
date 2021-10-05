local Transport = {}

function Transport:Constructor()
    self._queue = {}
    self._queueProcessing = false
    self._queueFails = 0
end

function Transport:API(payload, important)
    table.insert(self._queue, important and (self._queueProcessing and 2 or 1) or #self._queue + 1, payload)
    self:_ProcessQueue()
end

function Transport:_ProcessQueue()
    if not self._queueProcessing then
        self._queueProcessing = true

        local function handle()
            local item = self._queue[1]
            if not item then
                self._queueProcessing = false
                return
            end

            self:_API(item, function(success)
                if success then
                    table.remove(self._queue, 1)
                    self._queueFails = 0

                    if #self._queue > 0 then
                        handle()
                    else
                        self._queueProcessing = false
                    end
                else
                    self._queueFails = self._queueFails + 1

                    timer.Create(tostring(self), (self._queueFails <= 3 and 5 or 10 * math.min(self._queueFails - 3, 6)), 1, function()
                        handle()
                    end)
                end
            end)
        end

        handle()
    end
end

function Transport:_API()
    Error('Unimplemented function _API for Transport with the class of ' .. self.class .. '.')
end

function Transport:SetAuthToken(token)
    self._authtoken = token
end

function Transport:Destroy()
    self:_destroy()
end

function Transport:_destroy()
    self._queue = {}
    self._queueProcessing = false
    self._queueFails = 0
    timer.Destroy(tostring(self))
end

Discord.OOP:Register('BaseTransport', Transport, 'EventEmitter')