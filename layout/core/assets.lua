---@diagnostic disable: missing-fields

---@class FOXStencil.Layer

---@class FOXStencil.Assets
---@field themes FOXStencil.Themes
---@field layers FOXStencil.Layers
---@field widgets FOXStencil.Widgets
local assets = {
	themes = {},
	layers = {},
	widgets = {},
}

local path = table.concat({ ... }, "/"):gsub("(%w)%.(%w)", "%1/%2")
local assets_path = string.match(path, ".-/Stencil") .. "/assets"

local themes_paths = listFiles(assets_path .. "/themes", true)
for i = 1, #themes_paths do
	assets.themes[themes_paths[i]:match("%w*$")] = require(themes_paths[i])
end

local layers_paths = listFiles(assets_path .. "/layers", true)
for i = 1, #layers_paths do
	assets.layers[layers_paths[i]:match("%w*$")] = require(layers_paths[i])
end

local widgets_paths = listFiles(assets_path .. "/widgets", true)
for i = 1, #widgets_paths do
	assets.widgets[widgets_paths[i]:match("%w*$")] = require(widgets_paths[i])
end

return assets
