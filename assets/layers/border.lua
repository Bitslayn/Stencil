---Generates a border layer
---
---Call :setStyles() with a table to change the styles
---@alias FOXStencil.Border.Generator fun(part: ModelPart, elem: FOXStencil.Element): FOXStencil.Border

---@class FOXStencil.Layers
---@field border FOXStencil.Border.Generator

---@class FOXStencil.Border: FOXStencil.Layer
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Border.Styles
local default_styles = {
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
	weight = 1,

	---@type number
	depth = 1,

	---@type boolean
	visible = true,
}

---@class FOXStencil.Border.State
local default_state = {
	---@type Vector2
	pos = vec(0, 0),
	---@type Vector2
	size = vec(0, 0)
}

local text_offset = matrices.scale4(1, 1 / 10, 1)
	* matrices.translate4(-1, -1, 0)

---Redraws this label
function obj:draw()
	local styles = self.styles

	-- Calculate sizing

	local state = self.state
	state.pos = styles.anchor_pos * self.elem.state.size + styles.offset_pos
	state.size = styles.anchor_size * self.elem.state.size + styles.offset_size

	local weight = styles.weight

	local w_t, w_r, w_b, w_l = weight, weight, weight, weight

	local w, h = state.size:unpack()

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
				:matrix(matrices.translate4(-state.pos:augmented(styles.depth)) * mats[i] * text_offset)
				:backgroundColor(styles.color)
		end

		self.tasks[i]:visible(visible)
	end
end

local parser = require("./../../layout/core/parser") --[[@as FOXStencil.Core.Parser]]

---Sets the given styles
---@param styles FOXStencil.Border.Styles
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
	for i = 1, 4 do
		self.tasks[i]:remove()
	end
	return self
end

---@param part ModelPart
---@param elem FOXStencil.Element
return function(part, elem)
	---@type TextTask[]
	local tasks = {}
	---@class FOXStencil.Border
	local self = {
		tasks = tasks,
		styles = setmetatable({}, { __index = default_styles }),
		state = setmetatable({}, { __index = default_state }),
		elem = elem,
	}

	for i = 1, 4 do
		tasks[i] = part:newText("border-" .. math.random())
			:background(true)
			:light(15)
			:text("")
	end

	return setmetatable(self, obj)
end
