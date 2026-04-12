---@class FOXStencil
local api = {}

textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))
api.newLayout = require("./layout/class").new

local class = require("./element/class").class
local presets = listFiles(... .. "/widgets")
for i = 1, #presets do
	require(presets[i])(class)
end

return api