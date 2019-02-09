-- Aero-ts Client
-- Written by Crazyman32, ported to Roblox-TS by DataBrain


local ASYNC_TIMEOUT = 10

-- Abstract class for all Aero modules
local AeroClient = {
	Controllers = {};
	Modules     = {};
	Shared      = {};
	Services    = {};
	Player      = game:GetService("Players").LocalPlayer;
}

local mt = {__index = AeroClient}

local CollectionService = game:GetService("CollectionService")
local controllersFolder = script.Parent:WaitForChild("Controllers")
local sharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("Modules")
local TSInternalFolder = game:GetService("ReplicatedStorage"):WaitForChild("RobloxTS"):WaitForChild("Include")

local Aero = require(sharedModulesFolder:WaitForChild("Aero"))
local Promise = require(TSInternalFolder:WaitForChild("Promise"))
--local FastSpawn = require(sharedModulesFolder:WaitForChild("FastSpawn"))

-- Runtime override of Aero classes
function ExtendAeroClient(class)
	local classIndex = class.__index
	while (getmetatable(classIndex)) do
		classIndex = getmetatable(classIndex).__index
	end

	setmetatable(classIndex, mt)
end
ExtendAeroClient(Aero.Controller)

function AeroClient:RegisterEvent(eventName)
	local event = Aero.Event.new()
	self._events[eventName] = event
	return event
end


function AeroClient:FireEvent(eventName, ...)
	self._events[eventName]:Fire(...)
end


function AeroClient:ConnectEvent(eventName, func)
	return self._events[eventName]:Connect(func)
end


function AeroClient:WaitForEvent(eventName)
	return self._events[eventName]:Wait()
end

--[[ Deprecated
function AeroClient:WrapModule(tbl)
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

local loadedClientInterfaces = {}

function LoadClientInterface(serviceFolder, rootTable)
	local clientInterface = {}
	for _,v in pairs(serviceFolder:GetChildren()) do
		if (v:IsA("RemoteEvent")) then
			if (CollectionService:HasTag(v, "ServerAsync")) then
				local trackedResponses = {}

				local checkingTimeouts = false
				local checkTimeouts; checkTimeouts = function()
					if checkingTimeouts then return end
					checkingTimeouts = true
					delay(1, function()
						local loopActive = false
						for timestamp, responseMethods in pairs(trackedResponses) do
							if (tick() - timestamp) > ASYNC_TIMEOUT then
								trackedResponses[timestamp] = nil
								responseMethods.reject("Async call '" .. v.Name .. "' timed out on the server")
							else
								loopActive = true
							end
						end
						checkingTimeouts = false

						-- Run the loop again if there are still responses to be checked
						if loopActive then
							checkTimeouts()
						end
					end)
				end

				v.OnClientEvent:Connect(function(timestamp, ...)
					local promiseResponseMethods = trackedResponses[timestamp]
					if (promiseResponseMethods) then
						trackedResponses[timestamp] = nil
						promiseResponseMethods.Resolve(...)
					end
					checkTimeouts()
				end)

				-- Wrap async events in promise-returning function
				clientInterface[v.Name] = function(...)
					local args = {...}
					return Promise.new(function(resolve, reject)
						local timestamp = tick()
						trackedResponses[timestamp] = {Resolve = resolve, Reject = reject}
						v:FireServer(timestamp, unpack(args))
						checkTimeouts()
					end)
				end
			elseif (CollectionService:HasTag(v, "ServerAsyncVoid")) then
				-- Wrap async event in void function
				clientInterface[v.Name] = function(...)
					local timestamp = tick()
					v:FireServer(timestamp, ...)
				end
			elseif (CollectionService:HasTag(v, "ClientEvent") or CollectionService:HasTag(v, "AllClientsEvent")) then
				-- Wrap client event in a new custom event
				local event = Aero.Event.new()
				v.OnClientEvent:Connect(function(...)
					event:Fire(...)
				end)
				clientInterface[v.Name] = event
			end
		elseif (v:IsA("RemoteFunction")) then
			if (CollectionService:HasTag(v, "ServerSync")) then
				clientInterface[v.Name] = function(self, ...)
					return v:InvokeServer(...)
				end
			end
		end
	end
	if (next(clientInterface)) then
		rootTable[serviceFolder.Name] = clientInterface
		table.insert(loadedClientInterfaces, clientInterface)
	end
end


function LoadClientInterfaces()
	local function recur(search, rootTable)
		for _,child in pairs(search:GetChildren()) do
			if (child:IsA("Folder")) then
				LoadClientInterface(child, rootTable)
			end
			local qualifierTable = {}
			recur(child, qualifierTable)
			if next(qualifierTable) then
				rootTable[child.Name] = qualifierTable
			end
		end
	end
	local remoteServices = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("AeroRemoteServices")
	recur(remoteServices, AeroClient.Services)
end

local loadedControllers = {}


function LoadController(module, rootTable)
	local _exports = require(module)

	if typeof(_exports) == "table" then
		for _,export in pairs(_exports) do
			-- Static class should have an __index with a metatable of Aero.Controller
			if (typeof(export) == "table" and export.__index and getmetatable(export.__index) and getmetatable(export.__index) == Aero.Controller) then
				if (export.Disabled ~= true) then
					local controller = export.new()
					rootTable[module.Name] = controller
					table.insert(loadedControllers, controller)
				end
			end
		end
	end
end

function LoadControllers()
	local function recur(search, rootTable)
		for _,child in pairs(search:GetChildren()) do
			if (child:IsA("ModuleScript")) then
				LoadController(child, rootTable)
			else
				local qualifierTable = {}
				recur(child, qualifierTable)
				if next(qualifierTable) then
					rootTable[child.Name] = qualifierTable
				end
			end
		end
	end
	recur(controllersFolder, AeroClient.Controllers)
end


function Init()
	-- Load server-side services as client interfaces:
	LoadClientInterfaces()
	
	-- Load controllers:
	LoadControllers()
	
	-- Initialize controllers:
	Aero.CallAll(loadedControllers, false, "Init")
	
	-- Start controllers:
	Aero.CallAll(loadedControllers, true, "Start")

	-- Expose client framework globally:
	_G.AeroClient = AeroClient

end


Init()