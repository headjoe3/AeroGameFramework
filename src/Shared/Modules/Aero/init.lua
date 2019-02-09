local Service = require(script.Service)
local ClientInterface = require(script.ClientInterface)
local Controller = require(script.Controller)

local ServerAsync = require(script.ServerAsync)
local ServerAsyncVoid = require(script.ServerAsyncVoid)
local ServerSync = require(script.ServerSync)

local AllClientsEvent = require(script.AllClientsEvent)
local ClientEvent = require(script.ClientEvent)

local Event = require(script.Event)
local ListenerList = require(script.ListenerList)

local CallAll = require(script.CallAll)

local Aero = {
    Service = Service,
    ClientInterface = ClientInterface,
    Controller = Controller,

    ServerAsync = ServerAsync,
    ServerAsyncVoid = ServerAsyncVoid,
    ServerSync = ServerSync,

    ClientEvent = ClientEvent,
    AllClientsEvent = AllClientsEvent,
    
    Event = Event,
    ListenerList = ListenerList,

    GetServer = function() return _G.AeroServer end,
    GetClient = function() return _G.AeroClient end,
    WaitForServer = function()
        while not (_G.AeroServer) do wait() end
        return _G.AeroServer
    end,
    WaitForClient = function()
        while not (_G.AeroClient) do wait() end
        return _G.AeroClient
    end,

    CallAll = CallAll
}

return Aero