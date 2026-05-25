---Generates a border layer
---
---Call :setStyles() with a table to change the styles
---@alias FOXStencil.Border.Generator fun(part: ModelPart): FOXStencil.Border

---@class FOXStencil.Layers
---@field border FOXStencil.Border.Generator

---@class FOXStencil.Border: FOXStencil.Layer
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Border.Styles
local default = {
	---@type Vector3|Vector4
	color = vec(1, 1, 1, 1),

	---@type Vector2
	pos = vec(0, 0),
	---@type Vector2
	size = vec(0, 0),
	---@type number
	weight = 1,

	---@type boolean
	visible = true
}

---Redraws this label
---@param self FOXStencil.Border
local function draw(self)
	local styles = self.styles

	local weight = styles.weight

	local w_t, w_r, w_b, w_l = weight, weight, weight, weight

	local w, h = styles.size:unpack()

	local mats = {
		-- Top
		matrices.translate4(w_l, w_t, 0)
		* matrices.scale4(w + w_l + w_r, w_t, 1),

		-- Right
		matrices.translate4(-w, 0, 0)
		* matrices.scale4(w_r, h, 1),

		-- Bottom
		matrices.translate4(w_l, -h, 0)
		* matrices.scale4(w + w_l + w_r, w_b, 1),

		-- Left
		matrices.translate4(w_l, 0, 0)
		* matrices.scale4(w_l, h, 1),
	}

	for i = 1, 4 do
		local visible = weight > 0 and styles.visible

		if visible then
			self.tasks[i]
				:matrix(matrices.translate4(-styles.pos:augmented(1)) * mats[i])
				:color(styles.color)
		end

		self.tasks[i]:visible(visible)
	end
end

local copy = require("./../core/parser").copy

---Sets the given styles
---@param styles FOXStencil.Border.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.styles) then
		draw(self)
	end

	return self
end

---@param part ModelPart
return function(part)
	---@type SpriteTask[]
	local tasks = {}
	---@class FOXStencil.Border
	local self = {
		tasks = tasks,
		styles = setmetatable({}, { __index = default }),
	}

	for i = 1, 4 do
		tasks[i] = part:newSprite("border-" .. math.random())
			:texture(textures["FOXStencil_blank"], 1, 1)
			:renderType("CUTOUT_EMISSIVE_SOLID")
	end

	return setmetatable(self, obj)
end
