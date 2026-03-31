textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))

---@class Stencil.Elements
local class = {}
class.__index = class

function class:update()
	self[1]:update()
	self[2]:update()
	self[3]:update()
end

local a = require("./layers/slice")
local b = require("./layers/border")
local c = require("./layers/label")

return function(...)
	return setmetatable({
		a(...),
		b(...),
		c(...)
	}, class)
end
