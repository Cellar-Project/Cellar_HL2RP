local EventEmitter = {}

function EventEmitter:Constructor()
    self._events = {}
    self._any = {}
end

function EventEmitter:on(Event, Callback, id)
    self._events[Event] = self._events[Event] or {}

    if id then
        local new = {}

        for _, data in ipairs(self._events[Event]) do
            if data.id and data.id == id then continue end
            table.insert(new, data)
        end

        self._events[Event] = new
    end

    table.insert(self._events[Event], {
        once = false,
        id = id,
        Callback = Callback,
    })
end

function EventEmitter:once(Event, Callback, id)
    self._events[Event] = self._events[Event] or {}

    if id then
        local new = {}
        
        for _, data in ipairs(self._events[Event]) do
            if data.id and data.id == id then continue end
            table.insert(new, data)
        end

        self._events[Event] = new
    end

    table.insert(self._events[Event], {
        once = true,
        id = id,
        Callback = Callback,
    })
end

function EventEmitter:any(Callback)
    table.insert(self._any, Callback)
end

function EventEmitter:emit(Event, ...)
    if not self._events[Event] and #self._any == 0 then return end

    for i, event in ipairs(self._events[Event] or {}) do
        event.Callback(...)

        if event.once then
            table.remove(self._events[Event], i)
        end
    end

    for i, callback in ipairs(self._any) do
        callback(Event, ...)
    end
end

function EventEmitter:destroy()
    self._events = {}
    self._any = {}
end

Discord.OOP:Register('EventEmitter', EventEmitter)