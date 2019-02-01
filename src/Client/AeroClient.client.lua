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

local controllersFolder = script.Parent:WaitForChild("Controllers")
local sharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("Modules")
local TSInternalFolder = game:GetService("ReplicatedStorage"):WaitForChild("RobloxTS"):WaitForChild("Include")

local Aero = require(sharedModulesFolder:WaitForChild("Aero"))
local FastSpawn = require(sharedModulesFolder:WaitForChild("FastSpawn"))
local Promise = require(TSInternalFolder:WaitForChild("Promise"))

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

function LoadClientInterface(serviceFolder)
	local clientInterface = {}
	AeroClient.Services[serviceFolder.Name] = clientInterface
	for _,v in pairs(serviceFolder:GetChildren()) do
		if (v:IsA("RemoteEvent")) then
			if (game:GetService("CollectionService"):HasTag(v, "Async")) then
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
			elseif (game:GetService("CollectionService"):HasTag(v, "AsyncVoid")) then
				-- Wrap async event in void function
				clientInterface[v.Name] = function(...)
					local timestamp = tick()
					v:FireServer(timestamp, ...)
				end
			else
				-- Otherwise, wrap event normally
				local event = Aero.Event.new()
				local fireEvent = event.Fire
				function event:Fire(...)
					v:FireServer(...)
				end
				v.OnClientEvent:Connect(function(...)
					fireEvent(event, ...)
				end)
				clientInterface[v.Name] = event
			end
		elseif (v:IsA("RemoteFunction")) then
			if (game:GetService("CollectionService"):HasTag(v, "Sync")) then
				clientInterface[v.Name] = function(self, ...)
					return v:InvokeServer(...)
				end
			end
		end
	end
end


function LoadClientInterfaces()
	local remoteServices = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("AeroRemoteServices")
	for _,serviceFolder in pairs(remoteServices:GetChildren()) do
		if (serviceFolder:IsA("Folder")) then
			LoadClientInterface(serviceFolder)
		end
	end
end


function LoadController(module)
	local _exports = require(module)

	if typeof(_exports) == "table" then
		for _,export in pairs(_exports) do
			-- Static class should have an __index with a metatable of Aero.Controller
			if (typeof(export) == "table" and export.__index and getmetatable(export.__index) and getmetatable(export.__index) == Aero.Controller) then
				local controller = export.new()
				AeroClient.Controllers[module.Name] = controller
			end
		end
	end
end


function InitController(controller)
	if (type(controller.Init) == "function") then
		controller:Init()
	end
end


function StartController(controller)
	-- Start controllers on separate threads:
	if (type(controller.Start) == "function") then
		FastSpawn(controller.Start, controller)
	end
end


function Init()
	-- Load server-side services as client interfaces:
	LoadClientInterfaces()
	
	-- Load controllers:
	for _,module in pairs(controllersFolder:GetChildren()) do
		if (module:IsA("ModuleScript")) then
			LoadController(module)
		end
	end
	
	-- Initialize controllers:
	for _,controller in pairs(AeroClient.Controllers) do
		InitController(controller)
	end
	
	-- Start controllers:
	for _,controller in pairs(AeroClient.Controllers) do
		StartController(controller)
	end

	-- Expose client framework globally:
	_G.AeroClient = AeroClient

end


Init()