---Generates a button widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Button.Generator fun(part: ModelPart): FOXStencil.Button

---@class FOXStencil.Widgets
---@field button FOXStencil.Button.Generator

---@class FOXStencil.Button
local obj = {}
---@package
obj.__index = obj

function obj:meow()
	print("Meow")
end

return function(elem)
	return setmetatable({}, obj)
end
