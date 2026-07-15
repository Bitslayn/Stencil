---Generates a text layer
---@alias FOXStencil.Text.Generator fun(part: ModelPart, elem: FOXStencil.Element): FOXStencil.Text

---@class FOXStencil.Layers
---@field text FOXStencil.Text.Generator

---@class FOXStencil.Text: FOXStencil.Layer
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Text.Styles
local default_styles = {
	---@type string
	text = "",

	---@type Vector2
	offset_pos = vec(0, 0),
	---@type number
	offset_width = 0,

	---@type number
	size = 1,
	---@type Vector2
	align = vec(0, 0),

	---@type number
	depth = 1 / 16,

	---@type Vector3
	outline = vectors.intToRGB(0x202020),
	---@type boolean
	outline_state = false,
	---@type boolean
	shadow = false,

	---@type boolean
	wrap = true,

	---@type boolean
	visible = true,
}

---@class FOXStencil.Text.State
local default_state = {
	---@type Vector2
	pos = vec(0, 0),
	---@type number
	width = 0,
}

---Redraws this text
function obj:draw()
	local styles = self.styles

	-- Calculate sizing

	local state = self.state
	state.width = self.elem.state.size.x + styles.offset_width
	state.pos = styles.offset_pos
		+ styles.align
		* (self.elem.state.size - client.getTextDimensions(styles.text, state.width / styles.size) * styles.size)

	local visible = styles.text ~= "" and styles.visible

	if visible then
		self.task
			:text(styles.text)
			:width(styles.wrap and state.width / styles.size or nil)

			:pos(-state.pos:augmented(styles.depth))
			:scale(styles.size)

			:setOutline(styles.outline_state)
			:outlineColor(styles.outline)
			:shadow(styles.shadow)
	end

	self.task:visible(visible)
end

local parser = require("./../../layout/core/parser") --[[@as FOXStencil.Core.Parser]]

---Sets the given styles
---@param styles FOXStencil.Text.Styles
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
	---@class FOXStencil.Text
	local self = {
		task = part:newText("text-" .. math.random()):light(15),
		styles = setmetatable({}, { __index = default_styles }),
		state = setmetatable({}, { __index = default_state }),
		elem = elem,
	}

	return setmetatable(self, obj)
end
