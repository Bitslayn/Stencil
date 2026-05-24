textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1)) -- TODO Race condition when autoscripts is disabled

---@class FOXStencil
---@field layers FOXStencil.Layers
local api = {
	---@diagnostic disable-next-line: missing-fields
	layers = {},
	newScreen = require("./layout/screen"),
}

local layers = listFiles(... .. "/layout/layers")
for i = 1, #layers do
	api.layers[layers[i]:match("%w*$")] = require(layers[i])
end

local debug = listFiles(... .. "/debug")
for i = 1, #debug do
	require(debug[i])
end

return api
