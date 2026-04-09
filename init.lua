local api = {}

textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))

---@param part ModelPart
---@return FOXStencil.Layout
function api.newLayout(part)
	return require("./layout/class")(part)
end

return api