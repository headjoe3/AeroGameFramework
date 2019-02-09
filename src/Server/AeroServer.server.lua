-- Aero Server
-- Crazyman32
-- July 21, 2017



local AeroServer = {
	Services = {};
	Modules  = {};
	Shared   = {};
}

local mt = {__index = AeroServer}

local CollectionService = game:GetService("CollectionService")
local servicesFolder = game:GetService("ServerScriptService").Aero.Services
local sharedModulesFolder = game:GetService("ReplicatedStorage").Aero.Modules

local remoteServices = Instance.new("Folder")
remoteServices.Name = "AeroRemoteServices"

local Aero = require(sharedModulesFolder.Aero)
--local FastSpawn = require(sharedModulesFolder.FastSpawn)

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


function AeroServer:_RegisterClientEvent(eventName, event)
    if (not self._remoteFolder) then return end

	local remote = Instance.new("RemoteEvent")
	remote.Name = eventName
	remote.Parent = self._remoteFolder

	event:Connect(function(...)
		remote:FireClient(...)
	end)

    -- Add tag
    CollectionService:AddTag(remote, "ClientEvent")

	self._clientEvents[eventName] = remote
	return remote
end

function AeroServer:_RegisterAllClientsEvent(eventName, event)
    if (not self._remoteFolder) then return end

	local remote = Instance.new("RemoteEvent")
	remote.Name = eventName
	remote.Parent = self._remoteFolder

	event:Connect(function(...)
		remote:FireAllClients(...)
	end)

    -- Add tag
    CollectionService:AddTag(remote, "AllClientsEvent")

	self._clientEvents[eventName] = remote
	return remote
end

function AeroServer:_RegisterSyncFunction(funcName, func)
    if (not self._remoteFolder) then return end
    
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = funcName
	remoteFunc.OnServerInvoke = function(...)
		return func(...)
	end

    -- Add tag
    CollectionService:AddTag(remoteFunc, "ServerSync")

	remoteFunc.Parent = self._remoteFolder
	return remoteFunc
end


function AeroServer:_RegisterClientAsyncFunction(funcName, func, isVoid)
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
        CollectionService:AddTag(event, "ServerAsyncVoid")
    else
        CollectionService:AddTag(event, "ServerAsync")
    end

	event.Parent = self._remoteFolder
    return event
end

--[[ Deprecated
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
]]

local loadedServices = {}

-- Load service from module:
function LoadService(module, rootTable)
	
	local _exports = require(module)

	if typeof(_exports) == "table" then
        -- Load services in exports
		for _,export in pairs(_exports) do
			-- Static class should have an __index with a metatable of Aero.Service
            if (typeof(export) == "table" and export.__index and getmetatable(export.__index)) then
                if (getmetatable(export.__index) == Aero.Service) then
					if (export.Disabled ~= true) then
						-- Create and register service
						local service = export.new()
		
						rootTable[module.Name] = service
						table.insert(loadedServices, service)
						
						service._events = {}
						service._clientEvents = {}
					end
                end
            end
        end
    
        -- Load client interfaces in exports
		for _,export in pairs(_exports) do
            if (typeof(export) == "table" and export.__index and getmetatable(export.__index)) then
                if (getmetatable(export.__index) == Aero.ClientInterface) then
                    local service = rootTable[module.Name]
                    if (service and service.Disabled ~= true) then
                        -- Create client interface
                        local clientInterface = export.new(service)

                        -- Expose API to the client
                        local remoteFolder = Instance.new("Folder")
                        remoteFolder.Name = module.Name
                        remoteFolder.Parent = remoteServices

                        -- Tie into service
                        service._remoteFolder = remoteFolder
						service._clientInterface = clientInterface
						service.Client = clientInterface
						
						-- Register interface functions
						for funcName, data in pairs(service._clientInterface) do
							if (type(data) == "table") then
								if (data._isEvent) then
									if (data._isAllClients) then
										service:_RegisterAllClientsEvent(funcName, data._event)
									else
										service:_RegisterClientEvent(funcName, data._event)
									end
								elseif (data._isAsync ~= nil and data._func ~= nil) then
									if (data._isAsync == true) then
										service:_RegisterClientAsyncFunction(funcName, data._func, data._isVoid)
									elseif (data._isAsync == false) then
										service:_RegisterSyncFunction(funcName, data._func)
									end
								end
							end
						end
                    end
                end
            end
        end
    end

end

function LoadServices()
	local function recur(search, rootTable)
		for _,child in pairs(search:GetChildren()) do
			if (child:IsA("ModuleScript")) then
				LoadService(child, rootTable)
			else
				local qualifierTable = {}
				recur(child, qualifierTable)
				if next(qualifierTable) then
					rootTable[child.Name] = qualifierTable
				end
			end
		end
	end
	recur(servicesFolder, AeroServer.Services)
end


function Init()
	
	-- Load service modules:
	LoadServices()
	
	-- Initialize services:
	Aero.CallAll(loadedServices, false, "Init")
	
	-- Start services:
	Aero.CallAll(loadedServices, true, "Start")
	
	-- Expose server framework to client and global scope:
	remoteServices.Parent = game:GetService("ReplicatedStorage").Aero
	_G.AeroServer = AeroServer
    
end


Init()