---Generates a label layer
---
---Call :setStyles() with a table to change the styles
---@alias FOXStencil.Sprite.Generator fun(part: ModelPart, elem: FOXStencil.Element): FOXStencil.Sprite

---@class FOXStencil.Layers
---@field sprite FOXStencil.Sprite.Generator

---@class FOXStencil.Sprite: FOXStencil.Layer
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Sprite.Styles
local default_styles = {
	---@type Texture
	texture = nil,
	---@type Vector3|Vector4
	color = vec(1, 1, 1, 1),
	---@type boolean?
	grid = false,

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
	uv_pos = vec(0, 0),
	---@type Vector2
	uv_size = vec(1, 1),

	---@type boolean
	visible = true,
}

---@class FOXStencil.Sprite.State
local default_state = {
	---@type Vector2
	pos = vec(0, 0),
	---@type Vector2
	size = vec(0, 0),
}

---Redraws this label
function obj:draw()
	local styles = self.styles
	if not styles.texture then return end

	-- Calculate sizing

	local state = self.state
	state.pos = styles.anchor_pos * self.elem.state.size + styles.offset_pos
	state.size = styles.anchor_size * self.elem.state.size + styles.offset_size

	local dim = styles.texture:getDimensions()

	local visible = 0 < state.size:length() and styles.visible

	if visible then
		self.task
			:uv(styles.uv_pos / dim)
			:region((styles.grid and state.size or styles.uv_size) * 1000)

			:pos(-state.pos:augmented(styles.depth))
			:scale(state.size:augmented())

			:dimensions(dim * 1000)
			:texture(styles.texture)
			:color(styles.color)
	end

	self.task:visible(visible)
end

local parser = require("./../../layout/core/parser") --[[@as FOXStencil.Core.Parser]]

---Sets the given styles
---@param styles FOXStencil.Sprite.Styles
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
	self.task:remove()
	return self
end

---@param part ModelPart
---@param elem FOXStencil.Element
return function(part, elem)
	---@class FOXStencil.Sprite
	local self = {
		task = part:newSprite("sprite-" .. math.random())
			:size(1, 1)
			:renderType("CUTOUT_EMISSIVE_SOLID"),
		styles = setmetatable({}, { __index = default_styles }),
		state = setmetatable({}, { __index = default_state }),
		elem = elem,
	}

	return setmetatable(self, obj)
end
