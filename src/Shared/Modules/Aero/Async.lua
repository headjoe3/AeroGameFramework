local function Async(wrappedFunction)
    return {
        _isAsync = true,
        _isVoid = false,
        _func = wrappedFunction,
    }
end

return Async