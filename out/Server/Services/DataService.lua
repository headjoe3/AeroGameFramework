local TS = require(game:GetService("ReplicatedStorage").RobloxTS.Include.RuntimeLib);
local _exports = {};
local DataService, DataServiceClient;
local Aero = TS.import("ReplicatedStorage", "Aero", "Internal", "Aero");
local Cache = TS.import("ServerScriptService", "Aero", "Modules", "DataStoreCache");
local SCOPE = "PlayerData";
local AUTOSAVE_INTERVAL = 60;
local NAME_SCOPE_KEY_FORMAT = "name=%s;scope=%s";
local PLAYER_FAILED_EVENT = "PlayerFailed";
local GLOBAL_FAILED_EVENT = "GlobalFailed";
local CUSTOM_FAILED_EVENT = "CustomFailed";
local CLIENT_FAILED_EVENT = "Failed";
local playerCaches = {};
local customCaches = {};
local globalCache;
local boundToCloseFuncs = {};
do
	DataService = {};
	DataService.__index = setmetatable({
		GetPlayerCache = function(self, player)
			local cache = TS.map_get(playerCaches, player);
			if (not cache) then
				if (player.UserId > 0) then
					cache = Cache.new(tostring(player.UserId), SCOPE);
				else
					cache = Cache.new();
				end;
				TS.map_set(playerCaches, player, cache);
				cache.Failed:Connect(function(method, key, errMsg)
					self:FireEvent(PLAYER_FAILED_EVENT, player, method, key, errMsg);
					self:FireClientEvent(CLIENT_FAILED_EVENT, player, method, key, errMsg);
				end);
			end;
			return cache;
		end;
		GetCustomCache = function(self, name, scope)
			local nameScopeKey = string.format(NAME_SCOPE_KEY_FORMAT, name, scope);
			local cache = TS.map_get(customCaches, nameScopeKey);
			if (not cache) then
				cache = Cache.new(name, scope);
				TS.map_set(customCaches, nameScopeKey, cache);
				cache.Failed:Connect(function(method, key, errMsg)
					self:FireEvent(CUSTOM_FAILED_EVENT, name, scope, method, key, errMsg);
				end);
			end;
			return cache;
		end;
		Set = function(self, player, key, value)
			self:GetPlayerCache(player):Set(key, value);
		end;
		Get = function(self, player, key)
			return self:GetPlayerCache(player):Get(key);
		end;
		Remove = function(self, player, key)
			self:GetPlayerCache(player):Remove(key);
		end;
		SetGlobal = function(self, key, value)
			globalCache:Set(key, value);
		end;
		GetGlobal = function(self, key)
			return globalCache:Get(key);
		end;
		RemoveGlobal = function(self, key)
			globalCache:Remove(key);
		end;
		OnUpdateGlobal = function(self, key, callback)
			return globalCache:OnUpdate(key, callback);
		end;
		SetCustom = function(self, name, scope, key, value)
			self:GetCustomCache(name, scope):Set(key, value);
		end;
		GetCustom = function(self, name, scope, key)
			return self:GetCustomCache(name, scope):Get(key);
		end;
		RemoveCustom = function(self, name, scope, key)
			self:GetCustomCache(name, scope):Remove(key);
		end;
		OnUpdateCustom = function(self, name, scope, key, callback)
			return self:GetCustomCache(name, scope):OnUpdate(key, callback);
		end;
		Flush = function(self, player)
			self:GetPlayerCache(player):FlushAll();
		end;
		FlushKey = function(self, player, key)
			self:GetPlayerCache(player):Flush(key);
		end;
		FlushGlobal = function(self, key)
			globalCache:Flush(key);
		end;
		FlushAllGlobal = function(self)
			globalCache:FlushAll();
		end;
		FlushCustom = function(self, name, scope, key)
			self:GetCustomCache(name, scope):Flush(key);
		end;
		FlushAllCustom = function(self, name, scope, key)
			self:GetCustomCache(name, scope):FlushAll();
		end;
		FlushAll = function(self)
			TS.map_forEach(playerCaches, function(cache)
				cache:FlushAll();
			end);
			TS.map_forEach(customCaches, function(cache)
				cache:FlushAll();
			end);
			globalCache:FlushAll();
		end;
		FlushAllConcurrent = function(self)
			local numCaches = 0;
			local numFlushed = 0;
			TS.map_forEach(playerCaches, function()
				numCaches = numCaches + 1;
			end);
			TS.map_forEach(customCaches, function()
				numCaches = numCaches + 1;
			end);
			if numCaches == 0 then
				return;
			end;
			local IncFlushed = function()
				numFlushed = numFlushed + 1;
				if numFlushed == numCaches then
				end;
			end;
			TS.map_forEach(playerCaches, function(cache)
				print("Saving player cache", cache);
				cache:FlushAllConcurrent();
				IncFlushed();
			end);
			TS.map_forEach(customCaches, function(cache)
				print("Saving custom cache", cache);
				cache:FlushAll();
				IncFlushed();
			end);
			globalCache:FlushAll();
		end;
		BindToClose = function(self, func)
			TS.array_push(boundToCloseFuncs, func);
		end;
		AutoSaveLoop = function(self)
			while (not self.GameClosing) do
				self:FlushAll();
				wait(AUTOSAVE_INTERVAL);
			end;
		end;
		Start = function(self)
			self.GameClosing = false;
			local FireBoundToCloseCallbacks = function()
				local numBinded = #boundToCloseFuncs;
				if (numBinded == 0) then
					return;
				end;
				local numCompleted = 0;
				local maxWait = 20;
				local start = tick();
				TS.array_forEach(boundToCloseFuncs, function(func)
					pcall(func);
					numCompleted = (numCompleted + 1);
					if (numCompleted == numBinded) then
					end;
				end);
			end;
			local PlayerRemoving = function(player)
				if (self.GameClosing) then
					return;
				end;
				self:Flush(player);
				wait(5);
				local cache = TS.map_get(playerCaches, player);
				if cache then
					cache:Destroy();
					TS.map_delete(playerCaches, player);
				end;
			end;
			local GameClosing = function()
				self.GameClosing = true;
				print("Stalling game close", 1);
				FireBoundToCloseCallbacks();
				print("Stalling game close", 2);
				self:FlushAllConcurrent();
				print("Stalling game close", 3);
			end;
			game:GetService("Players").PlayerRemoving:Connect(PlayerRemoving);
			game:BindToClose(GameClosing);
			delay(AUTOSAVE_INTERVAL, function()
				self:AutoSaveLoop();
			end);
		end;
		Init = function(self)
			self:RegisterEvent(PLAYER_FAILED_EVENT);
			self:RegisterEvent(GLOBAL_FAILED_EVENT);
			self:RegisterEvent(CUSTOM_FAILED_EVENT);
			self:RegisterClientEvent(CLIENT_FAILED_EVENT);
			globalCache = Cache.new("global", "global");
			globalCache.Failed:Connect(function(method, key, errMsg)
				self:FireEvent(GLOBAL_FAILED_EVENT, method, key, errMsg);
			end);
		end;
	}, Aero.Service);
	DataService.new = function(...)
		return DataService.constructor(setmetatable({}, DataService), ...);
	end;
	DataService.constructor = function(self, ...)
		Aero.Service.constructor(self, ...);
		self.GameClosing = false;
		return self;
	end;
end;
do
	DataServiceClient = {};
	DataServiceClient.__index = setmetatable({}, Aero.ClientInterface);
	DataServiceClient.new = function(...)
		return DataServiceClient.constructor(setmetatable({}, DataServiceClient), ...);
	end;
	DataServiceClient.constructor = function(self, ...)
		Aero.ClientInterface.constructor(self, ...);
		self.Get = Aero.Sync(function(player, key)
			if TS.typeof(key) == "string" then
				return self.Server:Get(player, key);
			end;
		end);
		return self;
	end;
end;
_exports.DataService = DataService;
_exports.DataServiceClient = DataServiceClient;
return _exports;
