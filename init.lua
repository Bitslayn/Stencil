textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1)) -- TODO Race condition when autoscripts is disabled

---@class FOXStencil
---@field layers FOXStencil.Layers
---@field widgets FOXStencil.Widgets
local api = {
	---@diagnostic disable-next-line: missing-fields
	layers = {},
	---@diagnostic disable-next-line: missing-fields
	widgets = {},
	newScreen = require("./layout/screen"),
}

local layers = listFiles(... .. "/layout/layers")
for i = 1, #layers do
	api.layers[layers[i]:match("%w*$")] = require(layers[i])
end

local widgets = listFiles(... .. "/layout/widgets")
for i = 1, #widgets do
	api.widgets[widgets[i]:match("%w*$")] = require(widgets[i])
end

local debug = listFiles(... .. "/debug")
for i = 1, #debug do
	require(debug[i])
end

return api
