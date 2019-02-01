local Service = require(script.Service)
local ClientInterface = require(script.ClientInterface)
local Controller = require(script.Controller)

local Async = require(script.Async)
local AsyncVoid = require(script.AsyncVoid)
local Sync = require(script.Sync)

local Event = require(script.Event)
local ListenerList = require(script.ListenerList)

local Aero = {
    Service = Service,
    ClientInterface = ClientInterface,
    Controller = Controller,

    Async = Async,
    AsyncVoid = AsyncVoid,
    Sync = Sync,
    
    Event = Event,
    ListenerList = ListenerList,
}

return Aero