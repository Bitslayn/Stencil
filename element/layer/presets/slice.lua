---@param super FOXStencil.Layer
---@param elem FOXStencil.Element
return function(super, elem)
	---@class FOXStencil.Layer.Slice: FOXStencil.Layer
	---@field tasks SpriteTask[][]
	local class = {}
	---@package
	function class:__index(k)
		return class[k] or super[k]
	end

	---@class FOXStencil.Element
	elem = elem

	local getDimensions = textures["FOXStencil_blank"].getDimensions

	local vec2 = vectors.vec2
	local vec3 = vectors.vec3
	local vec4 = vectors.vec4
	local unpack2 = vec2().unpack
	local unpack4 = vec4().unpack
	local tostring = tostring
	local concat = table.concat

	---@return FOXStencil.Layer.Slice
	function elem:newSlice()
		local layer = super.new(self)

		---@class FOXStencil.Styles.Slice
		layer.styles[0] = {
			pos = vec(0, 0),
			size = vec(0, 0),

			color = vec(1, 1, 1, 1),
			texture = textures["FOXStencil_blank"],
			slice = vec(0, 0, 0, 0),
			region = vec(0, 0),
			uv = vec(0, 0),
			extend = vec(0, 0, 0, 0),
		}

		for y = 1, 3 do
			layer.tasks[y] = {}
			for x = 1, 3 do
				layer.tasks[y][x] = layer.elem.part:newSprite("slice-" .. layer.id .. "-" .. x .. y)
					:texture(textures["FOXStencil_blank"], 1, 1)
					:size(1, 1)
					:renderType("CUTOUT_EMISSIVE_SOLID")
			end
		end

		return setmetatable(layer, class) --[[@as FOXStencil.Layer.Slice]]
	end

	function class:draw()
		local styles = self.styles --[[@as FOXStencil.Styles.Slice]]
		local dim = getDimensions(styles.texture)

		local t, r, b, l = unpack4(styles.slice)
		local atlas_w, atlas_h = unpack2(styles.region)
		local model_w, model_h = unpack2(styles.size + styles.extend.yx + styles.extend.wz --[[@as Vector2]])
		local e_x = styles.extend.x
		local e_w = styles.extend.w

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

		-- Update slices

		for y = 1, 3 do
			for x = 1, 3 do
				self.tasks[y][x]
					:uv((styles.uv + vec2(e_atlas_x[x], e_atlas_y[y])) / dim)
					:region(e_atlas_w[x] * 1000, e_atlas_h[y] * 1000)
					:pos(-e_model_x[x] + styles.extend.w - styles.pos.x, -e_model_y[y] + styles.extend.x - styles.pos.y)
					:scale(e_model_w[x], e_model_h[y])
					:visible(0 < e_atlas_w[x] and 0 < e_atlas_h[y])
					:texture(styles.texture)
					:dimensions(dim * 1000)
					:color(styles.color)
			end
		end

		return self
	end
end
