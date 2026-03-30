textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))

local class = {}
class.__index = class

function class:update()
	self[1]:update()
	-- self[2]:update()
	self[3]:update()
end

local border = require("./layers/border")
local label = require("./layers/label")
local slice = require("./layers/slice")

return function(...)
	return setmetatable({
		border(...),
		nil,
		slice(...)
	}, class)
end