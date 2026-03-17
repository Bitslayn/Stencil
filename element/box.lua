local sten_pixl = textures:newTexture("sten_pixl", 1, 1):pixel(0, 0, vec(1, 1, 1))

---Creates an outline
---@param pivot ModelPart
---@param styl FOXStencil.Styles.Box
local function outline(pivot, styl)
	local tex = styl.texture
	local s = styl.line_weight
	local w, h = (styl.size + tex.extend.yx + tex.extend.wz):unpack()

	local hor = matrices.scale4(w + s * 2, s, 1)
	local ver = matrices.scale4(s, h, 1)

	local mats = {
		matrices.translate4(s, s, 0) * hor, -- Top
		matrices.translate4(-w, 0, 0) * ver, -- Right
		matrices.translate4(s, -h, 0) * hor, -- Bottom
		matrices.translate4(s, 0, 0) * ver, -- Left
	}

	for i = 1, 4 do
		pivot:newSprite("outline-" .. i)
			:texture(sten_pixl, 1, 1)
			:color(styl.line_color)
			:matrix(matrices.translate4(tex.extend.w, tex.extend.x) * mats[i])
			:renderType("CUTOUT_EMISSIVE_SOLID")
	end
end

---Creates a sprite
---@param pivot ModelPart
---@param styl FOXStencil.Styles.Box
local function sprite(pivot, styl)
	local tex = styl.texture
	local atlas = tex.atlas or sten_pixl
	local dim = atlas:getDimensions()

	pivot:newSprite("sprite")
		:texture(atlas)
		:dimensions(dim * vec(1000, 1000))
		:size(1, 1)
		:uv(tex.pos / dim)
		:region(tex.size * 1000)
		:scale(styl.size.xy_)
		:renderType("CUTOUT_EMISSIVE_SOLID")
		:color(styl.texture.color)
end

---Creates a 9 slice
---@param pivot ModelPart
---@param styl FOXStencil.Styles.Box
local function slice(pivot, styl)
	local tex = styl.texture
	local dim = tex.atlas:getDimensions()

	local t, r, b, l = tex.slice:unpack()
	local atlas_w, atlas_h = tex.size:unpack()
	local model_w, model_h = (styl.size + tex.extend.yx + tex.extend.wz):unpack()

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
				pivot:newSprite("slice-" .. x .. y)
					:texture(tex.atlas)
					:dimensions(dim * vec(1000, 1000))
					:size(1, 1)
					:uv((tex.pos + vec(e_atlas_x[x], e_atlas_y[y])) / dim)
					:region(e_atlas_w[x] * 1000, e_atlas_h[y] * 1000)
					:pos(-e_model_x[x] + tex.extend.w, -e_model_y[y] + tex.extend.x)
					:scale(e_model_w[x], e_model_h[y])
					:renderType("CUTOUT_EMISSIVE_SOLID")
					:color(styl.texture.color)
			end
		end
	end
end

---@param pivot ModelPart
---@param styl FOXStencil.Styles.Box
return function(pivot, styl)
	if styl.texture.slice:length() > 0 then
		slice(pivot, styl)
	else
		sprite(pivot, styl)
	end

	outline(pivot, styl)
end
