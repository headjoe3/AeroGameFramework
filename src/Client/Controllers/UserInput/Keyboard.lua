-- Keyboard
-- Crazyman32
-- December 28, 2017

--[[
	
	Boolean   Keyboard:IsDown(keyCode)
	Boolean   Keyboard:AreAllDown(keyCodes...)
	Boolean   Keyboard:AreAnyDown(keyCodes...)
	
	Keyboard.KeyDown(keyCode)
	Keyboard.KeyUp(keyCode)
	
--]]



local Keyboard = {}
Keyboard.__index = Keyboard

local userInput = game:GetService("UserInputService")

local modulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("Modules")
local Aero = require(modulesFolder:WaitForChild("Aero"))

function Keyboard:IsDown(keyCode)
	return userInput:IsKeyDown(keyCode)
end


function Keyboard:AreAllDown(...)
	for _,keyCode in pairs{...} do
		if (not userInput:IsKeyDown(keyCode)) then
			return false
		end
	end
	return true
end


function Keyboard:AreAnyDown(...)
	for _,keyCode in pairs{...} do
		if (userInput:IsKeyDown(keyCode)) then
			return true
		end
	end
	return false
end

function Keyboard.new()
	local self = setmetatable({}, Keyboard)

	self.KeyDown = Aero.Event.new()
	self.KeyUp = Aero.Event.new()
	
	userInput.InputBegan:Connect(function(input, processed)
		if (processed) then return end
		if (input.UserInputType == Enum.UserInputType.Keyboard) then
			self.KeyDown:Fire(input.KeyCode)
		end
	end)
	
	userInput.InputEnded:Connect(function(input, processed)
		if (input.UserInputType == Enum.UserInputType.Keyboard) then
			self.KeyUp:Fire(input.KeyCode)
		end
	end)

	return self
end

return Keyboard