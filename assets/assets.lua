---@diagnostic disable: missing-fields

---@alias FOXStencil.Theme table<string, table>

---@class FOXStencil.Layer
---@field setStyles function
---@field draw function
---@field remove function

---@class FOXStencil.Assets
---@field themes FOXStencil.Themes
---@field layers FOXStencil.Layers
---@field widgets FOXStencil.Widgets
local assets = {
	themes = {},
	layers = {},
	widgets = {},
}

-- Load themes

local themes_paths = listFiles(... .. "/themes", true)
for i = 1, #themes_paths do
	assets.themes[themes_paths[i]:match("%w*$")] = require(themes_paths[i])
end

-- Load layers

local layers_paths = listFiles(... .. "/layers", true)
for i = 1, #layers_paths do
	assets.layers[layers_paths[i]:match("%w*$")] = require(layers_paths[i])
end

-- Load widgets

local widgets_paths = listFiles(... .. "/widgets", true)
for i = 1, #widgets_paths do
	assets.widgets[widgets_paths[i]:match("%w*$")] = require(widgets_paths[i])
end

return assets
