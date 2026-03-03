---@param pivot ModelPart
---@param styl FOXStencil.Styles.Box
return function(pivot, styl)
	local mat = matrices.scale4((vec(1 / 2, 1 / 20) * styl.size * 2).xy_)
		* matrices.translate4(-1, -1, 0) -- Text background is offset by a single pixel, this fixes that

	pivot:newText("task")
		:text("")
		:backgroundColor(styl.color)
		:matrix(mat)
		:light(15)
end
