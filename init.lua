---@class FOXStencil
local api = {}

textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))
api.newScreen = require("./screen/screen").new

pcall(require, ... .. "/widget/widget")

local debug = listFiles(... .. "/debug")
for i = 1, #debug do
	require(debug[i])
end

return api
