local TS = require(game:GetService("ReplicatedStorage").RobloxTS.Include.RuntimeLib);
local _exports = {};
local MyController;
local Aero = TS.import("ReplicatedStorage", "Aero", "Internal", "Aero");
do
	MyController = {};
	MyController.__index = setmetatable({
		Start = function(self)
			self.Services.MyService.DoSomethingAsync("Hello"):andThen(function(str) return print((("Got async response '") .. str) .. "'"); end);
			self.Services.MyService.DoSomething2Async();
		end;
	}, Aero.Controller);
	MyController.new = function(...)
		return MyController.constructor(setmetatable({}, MyController), ...);
	end;
	MyController.constructor = function(self, ...)
		Aero.Controller.constructor(self, ...);
		return self;
	end;
end;
_exports.MyController = MyController;
return _exports;
