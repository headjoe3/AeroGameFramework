local Controller = {}

-- Members
Controller.__index = {
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
Controller.new = function(...)
    return Controller.constructor(setmetatable({}, Controller), ...)
end
Controller.constructor = function(self)
    self._events = {}
    return self
end

return Controller