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
	visible = true,
}

---@param atlas_len number
---@param model_len number
---@param slice_l number
---@param slice_r number
---@param clip_l number
---@param clip_r number
local function slice(atlas_len, model_len, slice_l, slice_r, clip_l, clip_r)
	-- Slice

	local atlas = { 0, slice_l, atlas_len - slice_r, atlas_len }
	local model = { 0, slice_l, model_len - slice_r, model_len }

	-- Clip before

	for i = 1, 3 do
		if clip_l < model_len and clip_l >= model[i] then
			if i ~= 2 then
				atlas[i] = atlas[i] - math.max(-1, model[i] - clip_l)
			end
			model[i] = clip_l
		end
	end

	-- Clip after

	for i = 2, 4 do
		if clip_r > 0 and clip_r <= model[i] then
			if i ~= 3 then
				atlas[i] = atlas[i] - math.max(0, model[i] - clip_r)
			end
			model[i] = clip_r
		end
	end

	return atlas, model
end

---Redraws this slice
---@param self FOXStencil.Slice
local function draw(self)
	local styles = self.styles

	-- Calculate slices

	local model_w, model_h = styles.size:unpack()
	local atlas_w, atlas_h = styles.uv_size:unpack()

	local slice_t, slice_r, slice_b, slice_l = styles.slice:unpack()

	local clip_x, clip_y = styles.clip_pos:unpack()
	local clip_w, clip_h = styles.clip_size:unpack()

	local e_atlas_x, e_model_x = slice(atlas_w, model_w, slice_l, slice_r, clip_x, clip_w + clip_x)
	local e_atlas_y, e_model_y = slice(atlas_h, model_h, slice_t, slice_b, clip_y, clip_h + clip_y)

	-- Update slices

	local dim = styles.texture:getDimensions()

	for y = 1, 3 do
		for x = 1, 3 do
			local model_pos = vec(e_model_x[x], e_model_y[y])
			local atlas_pos = vec(e_atlas_x[x], e_atlas_y[y])

			local model_size = vec(e_model_x[x + 1] - e_model_x[x], e_model_y[y + 1] - e_model_y[y])
			local atlas_size = vec(e_atlas_x[x + 1] - e_atlas_x[x], e_atlas_y[y + 1] - e_atlas_y[y])

			local visible = 0 < atlas_size:length() and styles.visible

			if visible then
				self.tasks[y][x]
					:uv((styles.uv_pos + atlas_pos) / dim)
					:region(atlas_size * 1000)

					:pos((-model_pos - styles.pos):augmented(0))
					:scale(model_size:augmented(0))

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
