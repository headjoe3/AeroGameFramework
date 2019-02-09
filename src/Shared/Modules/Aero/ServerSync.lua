local function ServerSync(wrappedFunction)
    return {
        _isServer = true,
        _isAsync = false,
        _isVoid = false,
        _func = wrappedFunction,
    }
end

return ServerSync