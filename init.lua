textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1)) -- TODO Race condition when autoscripts is disabled

local provider = require("./layout/core/provider")

---@class FOXStencil
---@field layers FOXStencil.Layers
---@field widgets FOXStencil.Widgets
local api = {
	layers = provider.layers,
	widgets = provider.widgets,
	newScreen = require("./layout/screen"),
}

local debug = listFiles(... .. "/debug")
for i = 1, #debug do
	require(debug[i])
end

return api
