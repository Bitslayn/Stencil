local assets = require("./assets/assets") --[[@as FOXStencil.Assets]]

---@class FOXStencil
---@field themes FOXStencil.Themes
---@field layers FOXStencil.Layers
---@field widgets FOXStencil.Widgets
local api = {
	themes = assets.themes,
	layers = assets.layers,
	widgets = assets.widgets,
	newScreen = require("./layout/screen"),
}

local debug = listFiles(... .. "/debug")
for i = 1, #debug do
	require(debug[i])
end

return api
