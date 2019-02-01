local ClientInterface = {}

-- Members
ClientInterface.__index = {
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
ClientInterface.new = function(...)
    return ClientInterface.constructor(setmetatable({}, ClientInterface), ...)
end
ClientInterface.constructor = function(self, server)
    self.Server = server
    self._events = {}
    return self
end

return ClientInterface