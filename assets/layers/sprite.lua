---Generates a label layer
---
---Call :setStyles() with a table to change the styles
---@alias FOXStencil.Sprite.Generator fun(part: ModelPart): FOXStencil.Sprite

---@class FOXStencil.Layers
---@field sprite FOXStencil.Sprite.Generator

---@class FOXStencil.Sprite: FOXStencil.Layer
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Sprite.Styles
local default = {
	---@type Texture
	texture = nil,
	---@type Vector3|Vector4
	color = vec(1, 1, 1, 1),
	---@type boolean?
	grid = false,

	---@type Vector2
	pos = vec(0, 0),
	---@type Vector2
	size = vec(0, 0),

	---@type Vector2
	uv_pos = vec(0, 0),
	---@type Vector2
	uv_size = vec(1, 1),

	---@type boolean
	visible = true,
}

---Redraws this label
---@param self FOXStencil.Sprite
local function draw(self)
	local styles = self.styles
	if not styles.texture then return end

	local dim = styles.texture:getDimensions()

	local visible = 0 < styles.size:length() and styles.visible
	local size = styles.grid and styles.size or styles.uv_size

	if visible then
		self.task
			:uv(styles.uv_pos / dim)
			:region(size * 1000)

			:pos(-styles.pos:augmented(0))
			:scale(styles.size:augmented())

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
function obj:setStyles(styles)
	if parser.copy(styles, self.styles) then
		draw(self)
	end

	return self
end

---Removes this layer from its parent
---@return self
function obj:remove()
	self.task:remove()
	return self
end

---@param part ModelPart
return function(part)
	---@class FOXStencil.Sprite
	local self = {
		task = part:newSprite("sprite-" .. math.random())
			:size(1, 1)
			:renderType("CUTOUT_EMISSIVE_SOLID"),
		styles = setmetatable({}, { __index = default }),
	}

	return setmetatable(self, obj)
end
