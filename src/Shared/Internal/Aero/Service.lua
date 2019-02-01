local Service = {}

-- Members
Service.__index = {
    ConnectEvent = function(self, name, listener)
    end,
    RegisterEvent = function(self, name)
    end,
    FireEvent = function(self, name)
    end,
    FireClientEvent = function(self, name, player, ...)
        local args = { ... }
    end,
    FireAllClientsEvent = function(self, name, ...)
        local args = { ... }
    end,
};

-- Statics
Service.new = function(...)
    return Service.constructor(setmetatable({}, Service), ...)
end
Service.constructor = function(self)
    self._events = {}
    return self
end

return Service