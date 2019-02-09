local function ClientEvent(wrappedEvent)
    return {
        _isServer = false,
        _isEvent = true,
        _isAllClients = true,
        _event = wrappedEvent,
    }
end

return ClientEvent