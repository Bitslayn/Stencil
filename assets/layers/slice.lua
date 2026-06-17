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
	texture = nil,
	---@type Vector3|Vector4
	color = vec(1, 1, 1, 1),

	pos = vec(0, 0),
	size = vec(0, 0),
	slice = vec(0, 0, 0, 0),

	uv_pos = vec(0, 0),
	uv_size = vec(0, 0),

	clip_pos = vec(0, 0),
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

-- ---@param ids string[]
-- ---@param vals [table, table, table, table]
-- ---@return boolean[]
-- local function diff(ids, vals)
-- 	local states = {}
-- 	for i = 1, 3 do
-- 		local id = vals[1][i] .. vals[2][i] .. vals[3][i] .. vals[4][i]
-- 		states[i] = ids[i] ~= id
-- 		ids[i] = id
-- 	end
-- 	return states
-- end

---Redraws this slice
---@param self FOXStencil.Slice
local function draw(self)
	local styles = self.styles
	if not styles.texture then return end

	-- Calculate slices

	local atlas_w, atlas_h = styles.uv_size:unpack()
	local model_w, model_h = styles.size:unpack()

	local slice_t, slice_r, slice_b, slice_l = styles.slice:unpack()

	local clip_x, clip_y = styles.clip_pos:unpack()
	local clip_w, clip_h = styles.clip_size:unpack()

	local e_atlas_x, e_model_x, e_atlas_w, e_model_w = slice(atlas_w, model_w, slice_l, slice_r, clip_x, clip_w + clip_x)
	local e_atlas_y, e_model_y, e_atlas_h, e_model_h = slice(atlas_h, model_h, slice_t, slice_b, clip_y, clip_h + clip_y)

	-- Diff check

	-- local diff_x = diff(self.ids_x, { e_atlas_x, e_model_x, e_atlas_w, e_model_w })
	-- local diff_y = diff(self.ids_y, { e_atlas_y, e_model_y, e_atlas_h, e_model_h })

	-- Update slices

	local dim = styles.texture:getDimensions()

	self.pivot:pos(-styles.pos.xy_)

	for y = 1, 3 do
		for x = 1, 3 do
			-- if diff_x[x] or diff_y[y] then
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
			-- end
		end
	end
end

local copy = require("./../../layout/core/parser").copy

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
	local pivot = part:newPart("slice")
	---@type SpriteTask[][]
	local cells = {}
	---@class FOXStencil.Slice
	local self = {
		pivot = pivot,
		cells = cells,
		-- ids_x = {},
		-- ids_y = {},
		styles = setmetatable({}, { __index = default }),
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
