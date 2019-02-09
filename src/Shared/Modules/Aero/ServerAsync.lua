local function ServerAsync(wrappedFunction)
    return {
        _isServer = true,
        _isAsync = true,
        _isVoid = false,
        _func = wrappedFunction,
    }
end

return ServerAsync