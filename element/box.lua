local tex = textures:newTexture("", 1, 1):pixel(0, 0, vec(1, 1, 1))

---@param pivot ModelPart
---@param styl FOXStencil.Styles.Box
return function(pivot, styl)
	pivot:newSprite("background")
		:texture(tex, 1, 1)
		:scale(styl.size.xy_)
		:renderType("CUTOUT_EMISSIVE_SOLID")
		:color(styl.color)
end
