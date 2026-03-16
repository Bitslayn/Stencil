---@param pivot ModelPart
---@param styl FOXStencil.Styles.Slice
return function(pivot, styl)
	local tex = styl.texture
	local dim = tex.atlas:getDimensions()

	local t, r, b, l = tex.slice:unpack()
	local atlas_w, atlas_h = tex.size:unpack()
	local model_w, model_h = styl.size:unpack()

	l = math.min(l, model_w / 2)
	r = math.min(r, model_w / 2)
	t = math.min(t, model_h / 2)
	b = math.min(b, model_h / 2)

	-- Row slices

	local e_atlas_x = { 0, l, atlas_w - r }
	local e_atlas_w = { l, atlas_w - l - r, r }
	local e_model_x = { 0, l, model_w - r }
	local e_model_w = { l, model_w - l - r, r }

	-- Column slices

	local e_atlas_y = { 0, t, atlas_h - b }
	local e_atlas_h = { t, atlas_h - t - b, b }
	local e_model_y = { 0, t, model_h - b }
	local e_model_h = { t, model_h - t - b, b }

	-- Create slices

	for y = 1, 3 do
		for x = 1, 3 do
			if e_model_w[x] > 0 and e_model_h[y] > 0 then
				pivot:newSprite("task-" .. x .. y)
					:texture(tex.atlas)
					:dimensions(dim * vec(1000, 1000))
					:size(1, 1)
					:uv((tex.pos + vec(e_atlas_x[x], e_atlas_y[y])) / dim)
					:region(e_atlas_w[x] * 1000, e_atlas_h[y] * 1000)
					:pos(-e_model_x[x], -e_model_y[y])
					:scale(e_model_w[x], e_model_h[y])
					:renderType("CUTOUT_EMISSIVE_SOLID")
			end
		end
	end
end
