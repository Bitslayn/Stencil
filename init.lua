textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1)) -- TODO Race condition when autoscripts is disabled

---@class FOXStencil
local api = {
	layers = {
		---Generates a border layer
		---
		---Call :setStyles() with a table to change the styles
		---@type fun(part: ModelPart): FOXStencil.Border
		border = require("./layout/layers/border"),
		---Generates a label layer
		---
		---Call :setStyles() with a table to change the styles
		---@type fun(part: ModelPart): FOXStencil.Label
		label = require("./layout/layers/label"),
		---Generates a slice layer
		---
		---Call :setStyles() with a table to change the styles
		---@type fun(part: ModelPart): FOXStencil.Slice
		slice = require("./layout/layers/slice"),
		---Generates a sprite layer
		---
		---Call :setStyles() with a table to change the styles
		---@type fun(part: ModelPart): FOXStencil.Sprite
		sprite = require("./layout/layers/sprite"),
	},
}

api.newScreen = require("./layout/screen").new

local debug = listFiles(... .. "/debug")
for i = 1, #debug do
	require(debug[i])
end

return api
