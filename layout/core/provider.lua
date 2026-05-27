---@diagnostic disable: missing-fields

---@class FOXStencil.Layer

---@class FOXStencil.Provider
---@field layers FOXStencil.Layers
---@field widgets FOXStencil.Widgets
local lib = {
	layers = {},
	widgets = {},
}

local layout_path = string.match(..., ".-/layout")

local layers_paths = listFiles(layout_path .. "/layers", true)
for i = 1, #layers_paths do
	lib.layers[layers_paths[i]:match("%w*$")] = require(layers_paths[i])
end

local widgets_paths = listFiles(layout_path .. "/widgets", true)
for i = 1, #widgets_paths do
	lib.widgets[widgets_paths[i]:match("%w*$")] = require(widgets_paths[i])
end

return lib
