local function Sync(wrappedFunction)
    return {
        _isAsync = false,
        _isVoid = false,
        _func = wrappedFunction,
    }
end

return Sync