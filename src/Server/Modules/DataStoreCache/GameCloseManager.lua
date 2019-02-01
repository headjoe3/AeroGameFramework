--[[
    Roblox does not allow the use of coroutine.yield() during a closing loop; This is an attempt to fix this issue.
]]

-- The number of BindToClose() loops to be created for last-minute asynchronous functions
local CLOSE_CHUNKS = 40

local requestBuffer = {}
local activated = false
local finished = false

-- Generate BindToClose chunks
for i = 1, CLOSE_CHUNKS do
    game:BindToClose(function()
        while (not activated) do wait() end
        while not finished do
            -- Consume next request
            local nextKey, nextBuffer
            for k,v in pairs(requestBuffer) do
                if not v.Processing then
                    nextKey, nextBuffer = k, v
                    nextBuffer.Processing = true
                    break
                end
                wait()
            end

            -- Run next request if one is found
            if (nextKey ~= nil and nextBuffer ~= nil) then
                local success, err = pcall(nextBuffer.Callback, unpack(nextBuffer.Args))
                if (not success) then
                    warn("Game:BindToClose() scheduled request failed because of error: " .. err)
                end

                requestBuffer[nextKey] = nil
            end

            wait(0.25)
        end
    end)
end


-- Do not return module as a class; instead use static members

local GameCloseManager = {}

function GameCloseManager.Schedule(func, ...)
    local uniqueKey = {}
    requestBuffer[uniqueKey] = {
        Callback = func,
        Args = {...},
        Processing = false,
    }
end

function GameCloseManager.HandleScheduledRequests()
    activated = true
end

function GameCloseManager.CompleteRequestsUntilFinished()
    while (next(requestBuffer)) do wait() end
    finished = true
end

function GameCloseManager.IsClosing()
    return activated
end

return GameCloseManager