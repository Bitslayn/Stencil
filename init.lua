---@class FOXStencil
local api = {}

textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))
api.newScreen = require("./screen/screen").new

local debug = listFiles(... .. "/debug")
for i = 1, #debug do
	require(debug[i])
end

pcall(require, ... .. "/widget/widget")

return api
