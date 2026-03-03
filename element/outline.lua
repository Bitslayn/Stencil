---@param pivot ModelPart
---@param styl FOXStencil.Styles.Outline
return function(pivot, styl)
	local w = styl.weight
	local x, y = styl.size:unpack()

	local box = matrices.scale4((vec(1 / 2, 1 / 20) * 2).xy_)
		* matrices.translate4(-1, -1, 0) -- Text background is offset by a single pixel, this fixes that

	local hor = matrices.scale4(x, w, 1) * box
	local ver = matrices.scale4(w, y - w * 2, 1) * box

	local mats = {
		hor, -- Top
		matrices.translate4(w - x, -w, 0) * ver, -- Right
		matrices.translate4(0, w - y, 0) * hor, -- Bottom
		matrices.translate4(0, -w, 0) * ver, -- Left
	}

	for i = 1, #mats do
		pivot:newText("task-" .. i)
			:text("")
			:backgroundColor(styl.color)
			:matrix(mats[i])
			:light(15)
	end
end
