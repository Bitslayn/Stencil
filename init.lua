textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))

---@class FOXStencil
local api = {
	layers = {
		---Generates a border layer
		---
		---Call :setStyles() with a table to change the styles
		---@type fun(part: ModelPart): FOXStencil.Border
		border = require(... .. "/layers/border"),
		---Generates a label layer
		---
		---Call :setStyles() with a table to change the styles
		---@type fun(part: ModelPart): FOXStencil.Label
		label = require(... .. "/layers/label"),
		---Generates a slice layer
		---
		---Call :setStyles() with a table to change the styles
		---@type fun(part: ModelPart): FOXStencil.Slice
		slice = require(... .. "/layers/slice"),
		---Generates a sprite layer
		---
		---Call :setStyles() with a table to change the styles
		---@type fun(part: ModelPart): FOXStencil.Sprite
		sprite = require(... .. "/layers/sprite"),
	},
}

api.newScreen = require("./screen/screen").new

local debug = listFiles(... .. "/debug")
for i = 1, #debug do
	require(debug[i])
end

pcall(require, ... .. "/widget/widget")

return api
