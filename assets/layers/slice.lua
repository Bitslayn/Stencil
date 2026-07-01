---Generates a slice layer
---
---Call :setStyles() with a table to change the styles
---@alias FOXStencil.Slice.Generator fun(part: ModelPart, elem: FOXStencil.Element): FOXStencil.Slice

---@class FOXStencil.Layers
---@field slice FOXStencil.Slice.Generator

---@class FOXStencil.Slice: FOXStencil.Layer
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Slice.Styles
local default_styles = {
	---@type Texture
	texture = nil,
	---@type Vector3|Vector4
	color = vec(1, 1, 1, 1),

	---@type Vector2
	anchor_pos = vec(0, 0),
	---@type Vector2
	anchor_size = vec(1, 1),
	---@type Vector2
	offset_pos = vec(0, 0),
	---@type Vector2
	offset_size = vec(0, 0),

	---@type number
	depth = 0,

	---@type Vector2
	pos = vec(0, 0),
	---@type Vector2
	size = vec(0, 0),
	---@type Vector4
	slice = vec(0, 0, 0, 0),

	---@type Vector2
	uv_pos = vec(0, 0),
	---@type Vector2
	uv_size = vec(0, 0),

	---@type Vector2
	clip_pos = vec(0, 0),
	---@type Vector2
	clip_size = vec(0, 0),

	---@type boolean
	visible = true,
}

---@class FOXStencil.Slice.State
local default_state = {
	---@type Vector2
	pos = vec(0, 0),
	---@type Vector2
	size = vec(0, 0),
}

---@param atlas_len number
---@param model_len number
---@param slice_l number
---@param slice_r number
---@param clip_l number
---@param clip_r number
---@return [number, number, number, number] atlas_points
---@return [number, number, number, number] model_points
---@return [number, number, number] atlas_sizes
---@return [number, number, number] model_sizes
local function slice(atlas_len, model_len, slice_l, slice_r, clip_l, clip_r)
	-- Slice

	slice_l = math.min(slice_l, model_len / 2)
	slice_r = math.min(slice_r, model_len / 2)

	local atlas_points = { 0, slice_l, atlas_len - slice_r, atlas_len }
	local model_points = { 0, slice_l, model_len - slice_r, model_len }

	-- Clip before

	for i = 1, 3 do
		if clip_l < model_len and clip_l >= model_points[i] then
			if i ~= 2 then
				atlas_points[i] = atlas_points[i] - math.max(-1, model_points[i] - clip_l)
			end
			model_points[i] = clip_l
		end
	end

	-- Clip after

	for i = 2, 4 do
		if clip_r > 0 and clip_r <= model_points[i] then
			if i ~= 3 then
				atlas_points[i] = atlas_points[i] - math.max(0, model_points[i] - clip_r)
			end
			model_points[i] = clip_r
		end
	end

	-- Sizing

	local atlas_sizes = { atlas_points[2] - atlas_points[1], atlas_points[3] - atlas_points[2], atlas_points[4] - atlas_points[3] }
	local model_sizes = { model_points[2] - model_points[1], model_points[3] - model_points[2], model_points[4] - model_points[3] }

	return atlas_points, model_points, atlas_sizes, model_sizes
end

---Redraws this slice
function obj:draw()
	local styles = self.styles
	if not styles.texture then return end

	-- Calculate sizing

	local state = self.state
	state.pos = styles.anchor_pos * self.elem.state.size + styles.offset_pos
	state.size = styles.anchor_size * self.elem.state.size + styles.offset_size

	-- Calculate slices

	local atlas_w, atlas_h = styles.uv_size:unpack()
	local model_w, model_h = state.size:unpack()

	local slice_t, slice_r, slice_b, slice_l = styles.slice:unpack()

	local clip_x, clip_y = styles.clip_pos:unpack()
	local clip_w, clip_h = styles.clip_size:unpack()

	local e_atlas_x, e_model_x, e_atlas_w, e_model_w = slice(atlas_w, model_w, slice_l, slice_r, clip_x, clip_w + clip_x)
	local e_atlas_y, e_model_y, e_atlas_h, e_model_h = slice(atlas_h, model_h, slice_t, slice_b, clip_y, clip_h + clip_y)

	-- Update slices

	local dim = styles.texture:getDimensions()

	self.pivot:pos(-state.pos:augmented(styles.depth))

	for y = 1, 3 do
		for x = 1, 3 do
			local atlas_pos = vec(e_atlas_x[x], e_atlas_y[y])
			local atlas_size = vec(e_atlas_w[x], e_atlas_h[y])

			local visible = 0 < atlas_size:length() and styles.visible

			if visible then
				self.cells[y][x]
					:dimensions(dim * 1000)
					:uvPixels((styles.uv_pos + atlas_pos) * 1000)
					:region(atlas_size * 1000)

					:pos(-e_model_x[x], -e_model_y[y])
					:scale(e_model_w[x], e_model_h[y])

					:texture(styles.texture)
					:color(styles.color)
			end

			self.cells[y][x]:visible(visible)
		end
	end
end

local parser = require("./../../layout/core/parser") --[[@as FOXStencil.Core.Parser]]

---Sets the given styles
---@param styles FOXStencil.Slice.Styles
---@return self
---@return boolean changed
function obj:setStyles(styles)
	if parser.copy(styles, self.styles) then
		self:draw()
		return self, true
	end

	return self, false
end

---Removes this layer from its parent
---@return self
function obj:remove()
	for y = 1, 3 do
		for x = 1, 3 do
			self.cells[y][x]:remove()
		end
	end
	return self
end

---@param part ModelPart
---@param elem FOXStencil.Element
return function(part, elem)
	local pivot = part:newPart("slice")
	---@type SpriteTask[][]
	local cells = {}
	---@class FOXStencil.Slice
	local self = {
		pivot = pivot,
		cells = cells,
		styles = setmetatable({}, { __index = default_styles }),
		state = setmetatable({}, { __index = default_state }),
		elem = elem,
	}

	for y = 1, 3 do
		cells[y] = {}
		for x = 1, 3 do
			cells[y][x] = pivot:newSprite("node-" .. math.random())
				:renderType("CUTOUT_EMISSIVE_SOLID")
				:size(1, 1)
		end
	end

	return setmetatable(self, obj)
end
