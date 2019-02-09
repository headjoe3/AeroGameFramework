local ClientInterface = {}

-- Members
ClientInterface.__index = {
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