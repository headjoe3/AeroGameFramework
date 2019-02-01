local TS = require(game:GetService("ReplicatedStorage").RobloxTS.Include.RuntimeLib);
local _exports = {};
local MyService, MyServiceClient;
local Aero = TS.import("ReplicatedStorage", "Aero", "Internal", "Aero");
do
	MyService = {};
	MyService.__index = setmetatable({
		Init = function(self)
			self:RegisterEvent("Hello!");
		end;
		Start = function(self)
			self:DoThing();
			self:ConnectEvent("Hello", function(whom)
			end);
			print("Hello service!");
		end;
		DoOtherThing = function(self)
		end;
		DoThing = function(self)
			self.Services.MyService:DoOtherThing();
		end;
	}, Aero.Service);
	MyService.new = function(...)
		return MyService.constructor(setmetatable({}, MyService), ...);
	end;
	MyService.constructor = function(self, ...)
		Aero.Service.constructor(self, ...);
		return self;
	end;
end;
do
	MyServiceClient = {};
	MyServiceClient.__index = setmetatable({}, Aero.ClientInterface);
	MyServiceClient.new = function(...)
		return MyServiceClient.constructor(setmetatable({}, MyServiceClient), ...);
	end;
	MyServiceClient.constructor = function(self, ...)
		Aero.ClientInterface.constructor(self, ...);
		self.DoSomething = Aero.Sync(function()
			self.Server:DoThing();
		end);
		self.DoSomethingAsync = Aero.Async(function(player, arg1)
			return ("Hello from ") .. tostring(self.Server);
		end);
		self.DoSomething2Async = Aero.AsyncVoid(function(player, arg1)
			print("Hello async void");
		end);
		return self;
	end;
end;
_exports.MyService = MyService;
_exports.MyServiceClient = MyServiceClient;
return _exports;
