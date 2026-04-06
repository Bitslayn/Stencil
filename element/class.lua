---@class Stencil.Elements
---@field layers any[]
---@field parn Stencil.Element
local class = {}
class.__index = class

function class:draw(lace)
	self.parn.part:pos(-self.parn.stat.pos:augmented(lace))

	for i = 1, #self.layers do
		self.layers[i]:draw()
	end
end

textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))

local new = {
	slice = require("./task/slice"),
	border = require("./task/border"),
	label = require("./task/label")
}

return function(...)
	return setmetatable({
		layers = {
			new.slice(...),
			new.border(...),
			new.label(...),
		},
		parn = ...,
	}, class)
end
