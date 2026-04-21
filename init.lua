---@class FOXStencil
local api = {}

textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))
api.newLayout = require("./layout/class").new

require("./widget/class")

return api