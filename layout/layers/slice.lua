---Generates a slice layer
---
---Call :setStyles() with a table to change the styles
---@alias FOXStencil.Slice.Generator fun(part: ModelPart): FOXStencil.Slice

---@class FOXStencil.Layers
---@field slice FOXStencil.Slice.Generator

---@class FOXStencil.Slice: FOXStencil.Layer
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Slice.Styles
local default = {
	---@type Texture
	texture = textures["FOXStencil_blank"],
	---@type Vector3|Vector4
	color = vec(1, 1, 1, 1),

	---@type Vector2
	pos = vec(0, 0),
	---@type Vector2
	size = vec(0, 0),
	---@type Vector4
	slice = vec(0, 0, 0, 0),

	---@type Vector2
	uv_pos = vec(0, 0),
	---@type Vector2
	uv_size = vec(1, 1),

	---@type Vector2
	clip_pos = vec(0, 0),
	---@type Vector2
	clip_size = vec(0, 0),

	---@type boolean
	visible = true
}

---Redraws this slice
---@param self FOXStencil.Slice
local function draw(self)
	local styles = self.styles

	local model_w, model_h = styles.size:unpack()
	local atlas_w, atlas_h = styles.uv_size:unpack()

	local slice_t, slice_r, slice_b, slice_l = styles.slice:unpack()

	-- Row slices

	local e_atlas_x = { 0, slice_l, atlas_w - slice_r }
	local e_atlas_w = { slice_l, atlas_w - slice_l - slice_r, slice_r }
	local e_model_x = { 0, slice_l, model_w - slice_r }
	local e_model_w = { slice_l, model_w - slice_l - slice_r, slice_r }

	-- Column slices

	local e_atlas_y = { 0, slice_t, atlas_h - slice_b }
	local e_atlas_h = { slice_t, atlas_h - slice_t - slice_b, slice_b }
	local e_model_y = { 0, slice_t, model_h - slice_b }
	local e_model_h = { slice_t, model_h - slice_t - slice_b, slice_b }

	-- Crop region

	local reg_pos = styles.clip_pos or vec(0, 0)
	local reg_size = styles.clip_size ~= vec(0, 0) and styles.clip_size or styles.size
	local reg_x, reg_y = (reg_size + reg_pos):unpack()
	local marker_x, marker_y = reg_pos:unpack()

	-- Crop along x

	for i = 1, 3 do
		-- Clip after (right)

		reg_x = reg_x - e_model_w[i]
		if reg_x < 0 then
			e_model_w[i] = e_model_w[i] + reg_x
			if i ~= 2 then
				e_atlas_w[i] = e_atlas_w[i] + reg_x
			end
			reg_x = 0
		end

		-- Clip before (left)

		local t = e_model_w[i]
		if 0 < marker_x then
			e_model_x[i] = math.max(e_model_x[i] + marker_x, 0)
			e_model_w[i] = math.max(e_model_w[i] - marker_x, 0)
			if i ~= 2 then
				e_atlas_x[i] = e_atlas_x[i] + marker_x
				e_atlas_w[i] = e_atlas_w[i] - marker_x
			end
		end
		marker_x = marker_x - t
	end

	-- Crop along y

	for i = 1, 3 do
		-- Clip after (below)

		reg_y = reg_y - e_model_h[i]
		if reg_y < 0 then
			e_model_h[i] = e_model_h[i] + reg_y
			if i ~= 2 then
				e_atlas_h[i] = e_atlas_h[i] + reg_y
			end
			reg_y = 0
		end

		-- Clip before (above)

		local t = e_model_h[i]
		if 0 < marker_y then
			e_model_y[i] = math.max(e_model_y[i] + marker_y, 0)
			e_model_h[i] = math.max(e_model_h[i] - marker_y, 0)
			if i ~= 2 then
				e_atlas_y[i] = e_atlas_y[i] + marker_y
				e_atlas_h[i] = e_atlas_h[i] - marker_y
			end
		end
		marker_y = marker_y - t
	end

	-- Update slices

	local pos_x, pos_y = styles.pos:unpack()
	local dim = styles.texture:getDimensions()

	for y = 1, 3 do
		for x = 1, 3 do
			local visible = 0 < e_atlas_w[x] and 0 < e_atlas_h[y] and styles.visible

			if visible then
				self.tasks[y][x]
					:uv((styles.uv_pos + vec(e_atlas_x[x], e_atlas_y[y])) / dim)
					:region(e_atlas_w[x] * 1000, e_atlas_h[y] * 1000)

					:pos(-e_model_x[x] - pos_x, -e_model_y[y] - pos_y)
					:scale(e_model_w[x], e_model_h[y])

					:dimensions(dim * 1000)
					:texture(styles.texture)
					:color(styles.color)
			end

			self.tasks[y][x]:visible(visible)
		end
	end
end

local copy = require("./../core/parser").copy

---Sets the given styles
---@param styles FOXStencil.Slice.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.styles) then
		draw(self)
	end

	return self
end

---@param part ModelPart
return function(part)
	---@type SpriteTask[][]
	local tasks = {}
	---@class FOXStencil.Slice
	local self = {
		tasks = tasks,
		styles = setmetatable({}, { __index = default }),
	}

	for y = 1, 3 do
		tasks[y] = {}
		for x = 1, 3 do
			tasks[y][x] = part:newSprite("slice-" .. math.random())
				:size(1, 1)
				:renderType("CUTOUT_EMISSIVE_SOLID")
		end
	end

	return setmetatable(self, obj)
end
