local function AsyncVoid(wrappedFunction)
    return {
        _isAsync = true,
        _isVoid = true,
        _func = wrappedFunction,
    }
end

return AsyncVoid