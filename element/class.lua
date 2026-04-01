---@class Stencil.Elements
---@field layers any[]
---@field parn Stencil.Element
local class = {}
class.__index = class

function class:draw(lace)
	self.parn.part:pos(-self.parn.stat.pos:augmented(lace))

	self.layers[1]:draw()
	self.layers[2]:draw()
	self.layers[3]:draw()
end

textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))

local a = require("./layers/slice")
local b = require("./layers/border")
local c = require("./layers/label")

return function(...)
	return setmetatable({
		layers = {
			a(...),
			b(...),
			c(...),
		},
		parn = ...,
	}, class)
end
