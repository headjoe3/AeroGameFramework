local function ServerAsyncVoid(wrappedFunction)
    return {
        _isServer = true,
        _isAsync = true,
        _isVoid = true,
        _func = wrappedFunction,
    }
end

return ServerAsyncVoid