local FastSpawn = require(script.Parent.Parent.FastSpawn)

function CallAll(componentList, asynchronous, functionName, ...)
    for _,component in pairs(componentList) do
        if typeof(component) == "table" and typeof(component[functionName]) == "function" then
            if (asynchronous) then
                FastSpawn(component[functionName], component, ...)
            else
                component[functionName](component, ...)
            end
        end
    end
end

return CallAll