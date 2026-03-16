---@param pivot ModelPart
---@param styl FOXStencil.Styles.Slice
return function(pivot, styl)
	local tex = styl.texture
	local dim = tex.atlas:getDimensions()

	local t, r, b, l = tex.slice:unpack()
	local w, h = tex.size:unpack()
	
	styl.size.x = math.max(styl.size.x, l + r)
	styl.size.y = math.max(styl.size.y, t + b)

	-- Center slice
	
	local c_atlas_w = w - l - r
	local c_atlas_h = h - t - b
	local c_model_w = styl.size.x - l - r
	local c_model_h = styl.size.y - t - b

	-- Row slices

	local e_atlas_x = { 0, l, l + c_atlas_w }
	local e_atlas_w = { l, c_atlas_w, r }
	local e_model_x = { 0, -l, -l - c_model_w }
	local e_model_w = { l, c_model_w, r }

	-- Column slices

	local e_atlas_y = { 0, t, t + c_atlas_h }
	local e_atlas_h = { t, c_atlas_h, b }
	local e_model_y = { 0, -t, -t - c_model_h }
	local e_model_h = { t, c_model_h, b }

	-- Create slices

	for y = 1, 3 do
		for x = 1, 3 do
			if e_model_w[x] > 0 and e_model_h[y] > 0 then
				pivot:newSprite("task-" .. x .. y)
					:texture(tex.atlas)
					:dimensions(dim)
					:size(1, 1)
					:uvPixels(tex.pos + vec(e_atlas_x[x], e_atlas_y[y]))
					:region(e_atlas_w[x], e_atlas_h[y])
					:pos(e_model_x[x], e_model_y[y])
					:scale(e_model_w[x], e_model_h[y])
					:renderType("CUTOUT_EMISSIVE_SOLID")
			end
		end
	end
end
