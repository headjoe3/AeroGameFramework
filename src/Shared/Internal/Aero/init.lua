local Service = require(script.Service)
local ClientInterface = require(script.ClientInterface)
local Controller = require(script.Controller)
local Event = require(script.Event)
local Async = require(script.Async)
local AsyncVoid = require(script.AsyncVoid)
local Sync = require(script.Sync)

local Aero = {
    Service = Service,
    ClientInterface = ClientInterface,
    Controller = Controller,
    Event = Event,
    Async = Async,
    AsyncVoid = AsyncVoid,
    Sync = Sync,
}

return Aero