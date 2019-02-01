-- Aero Server
-- Crazyman32
-- July 21, 2017



local AeroServer = {
	Services = {};
	Modules  = {};
	Shared   = {};
}

local mt = {__index = AeroServer}

local servicesFolder = game:GetService("ServerScriptService").Aero.Services
local modulesFolder = game:GetService("ServerScriptService").Aero.Modules
local sharedFolder = game:GetService("ReplicatedStorage").Aero.Modules
local internalFolder = game:GetService("ReplicatedStorage").Aero.Internal

local remoteServices = Instance.new("Folder")
remoteServices.Name = "AeroRemoteServices"

local Aero = require(internalFolder.Aero)
local FastSpawn = require(internalFolder.FastSpawn)

-- Runtime override of Aero classes
function ExtendAeroServer(class)
	local classIndex = class.__index
	while (getmetatable(classIndex)) do
		classIndex = getmetatable(classIndex).__index
	end

	setmetatable(classIndex, mt)
end
ExtendAeroServer(Aero.Service)


function AeroServer:RegisterEvent(eventName)
	local event = Aero.Event.new()
	self._events[eventName] = event
	return event
end


function AeroServer:RegisterClientEvent(eventName)
    if (not self._remoteFolder) then return end

	local event = Instance.new("RemoteEvent")
	event.Name = eventName
	event.Parent = self._remoteFolder
	self._clientEvents[eventName] = event
	return event
end


function AeroServer:FireEvent(eventName, ...)
	self._events[eventName]:Fire(...)
end


function AeroServer:FireClientEvent(eventName, client, ...)
	self._clientEvents[eventName]:FireClient(client, ...)
end


function AeroServer:FireAllClientsEvent(eventName, ...)
	self._clientEvents[eventName]:FireAllClients(...)
end


function AeroServer:ConnectEvent(eventName, func)
	return self._events[eventName]:Connect(func)
end


function AeroServer:ConnectClientEvent(eventName, func)
	return self._clientEvents[eventName].OnServerEvent:Connect(func)
end


function AeroServer:WaitForEvent(eventName)
	return self._events[eventName]:Wait()
end


function AeroServer:WaitForClientEvent(eventName)
	return self._clientEvents[eventName]:Wait()
end


function AeroServer:RegisterSyncFunction(funcName, func)
    if (not self._remoteFolder) then return end
    
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = funcName
	remoteFunc.OnServerInvoke = function(...)
		return func(self._clientInterface, ...)
	end

    -- Add tag
    game:GetService("CollectionService"):AddTag(remoteFunc, "Sync")

	remoteFunc.Parent = self._remoteFolder
	return remoteFunc
end


function AeroServer:RegisterClientAsyncFunction(funcName, func, isVoid)
    if (not self._remoteFolder) then return end
    
    -- Create event
    local event = Instance.new("RemoteEvent")
	event.Name = funcName
    event.OnServerEvent:Connect(function(player, timestamp, ...)
        local returnValues = {func(player, ...)}
        if (not isVoid) then
            -- Fire back to the client
            event:FireClient(player, timestamp, unpack(returnValues))
        end
    end)

    -- Add tag
    if (isVoid) then
        game:GetService("CollectionService"):AddTag(event, "AsyncVoid")
    else
        game:GetService("CollectionService"):AddTag(event, "Async")
    end

	event.Parent = self._remoteFolder
    return event
end


function AeroServer:WrapModule(tbl)
	assert(type(tbl) == "table", "Expected table for argument")
	tbl._events = {}
	setmetatable(tbl, mt)
	if (type(tbl.Init) == "function" and not tbl.__aeroPreventInit) then
		tbl:Init()
	end
	if (type(tbl.Start) == "function" and not tbl.__aeroPreventStart) then
		FastSpawn(tbl.Start, tbl)
	end
end


-- Setup table to load modules on demand:
function LazyLoadSetup(tbl, folder)
	setmetatable(tbl, {
		__index = function(t, i)
			local obj = require(folder[i])
			if (type(obj) == "table") then
				AeroServer:WrapModule(obj)
			end
			rawset(t, i, obj)
			return obj
		end;
	})
end


-- Load service from module:
function LoadService(module)
	
	local _exports = require(module)

	if typeof(_exports) == "table" then
        -- Load services in exports
		for _,export in pairs(_exports) do
			-- Static class should have an __index with a metatable of Aero.Service
            if (typeof(export) == "table" and export.__index and getmetatable(export.__index)) then
                if (getmetatable(export.__index) == Aero.Service) then
                    -- Create and register service
                    local service = export.new()
    
                    AeroServer.Services[module.Name] = service
                    
                    service._events = {}
                    service._clientEvents = {}
                end
            end
        end
    
        -- Load client interfaces in exports
		for _,export in pairs(_exports) do
            if (typeof(export) == "table" and export.__index and getmetatable(export.__index)) then
                if (getmetatable(export.__index) == Aero.ClientInterface) then
                    local service = AeroServer.Services[module.Name]
                    if (service) then
                        -- Create client interface
                        local clientInterface = export.new(service)

                        -- Expose API to the client
                        local remoteFolder = Instance.new("Folder")
                        remoteFolder.Name = module.Name
                        remoteFolder.Parent = remoteServices

                        -- Tie into service
                        service._remoteFolder = remoteFolder
                        service._clientInterface = clientInterface
                    end
                end
            end
        end
    end

end


function InitService(service)
	
	-- Initialize:
	if (type(service.Init) == "function") then
		service:Init()
	end
	
    -- Expose client interface members:
    if (service._clientInterface) then
        for funcName, data in pairs(service._clientInterface) do
            if (type(data) == "table" and data._isAsync ~= nil and data._func ~= nil) then
                if (data._isAsync == true) then
                    service:RegisterClientAsyncFunction(funcName, data._func, data._isVoid)
                elseif (data._isAsync == false) then
                    service:RegisterSyncFunction(funcName, data._func)
                end
            end
        end
    end
	
end


function StartService(service)

	-- Start services on separate threads:
	if (type(service.Start) == "function") then
		FastSpawn(service.Start, service)
	end

end


function Init()
	
	-- Lazy-load server and shared modules:
	LazyLoadSetup(AeroServer.Modules, modulesFolder)
	LazyLoadSetup(AeroServer.Shared, sharedFolder)
	
	-- Load service modules:
	for _,module in pairs(servicesFolder:GetChildren()) do
		if (module:IsA("ModuleScript")) then
			LoadService(module)
		end
	end
	
	-- Initialize services:
	for _,service in pairs(AeroServer.Services) do
		InitService(service)
	end
	
	-- Start services:
	for _,service in pairs(AeroServer.Services) do
		StartService(service)
	end
	
	-- Expose server framework to client and global scope:
	remoteServices.Parent = game:GetService("ReplicatedStorage").Aero
	_G.AeroServer = AeroServer
    
end


Init()