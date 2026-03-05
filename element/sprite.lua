---@param pivot ModelPart
---@param styl FOXStencil.Styles.Sprite
return function(pivot, styl)
	local dim = styl.texture:getDimensions()
	local size = styl.size

	pivot:newSprite("sprite")
		:texture(styl.texture)
		:dimensions(dim)
		:region(dim)
		:size(vec(1, 1))
		:scale(size.xy_)
end