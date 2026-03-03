---@param pivot ModelPart
---@param styl FOXStencil.Styles.Slice
return function(pivot, styl)
	local tex = styl.texture
	local dim = tex.atlas:getDimensions()

	local t, r, b, l = tex.slice:unpack()
	local w, h = tex.size:unpack()
	
	styl.size.x = math.max(styl.size.x, l + r)
	styl.size.y = math.max(styl.size.y, t + b)
	
	local c_w = w - l - r
	local c_h = h - t - b
	local s_w = styl.size.x - l - r
	local s_h = styl.size.y - t - b

	local pos_x = { 0, -l, -l - s_w }
	local size_x = { l, s_w, r }
	local uv_x = { 0, l, l + c_w }
	local reg_x = { l, c_w, r }

	local pos_y = { 0, -t, -t - s_h }
	local size_y = { t, s_h, b }
	local uv_y = { 0, t, t + c_h }
	local reg_y = { t, c_h, b }

	for y = 1, 3 do
		for x = 1, 3 do
			if size_x[x] > 0 and size_y[y] > 0 then
				pivot:newSprite("task-" .. x .. y)
					:texture(tex.atlas)
					:dimensions(dim)
					:size(1, 1)
					:pos(pos_x[x], pos_y[y])
					:scale(size_x[x], size_y[y])
					:uvPixels(tex.pos + vec(uv_x[x], uv_y[y]))
					:region(reg_x[x], reg_y[y])
					:renderType("CUTOUT_EMISSIVE_SOLID")
			end
		end
	end
end
