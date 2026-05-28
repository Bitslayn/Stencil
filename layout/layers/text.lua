---Generates a text layer
---
---Call :setStyles() with a table to change the styles
---@alias FOXStencil.Text.Generator fun(part: ModelPart): FOXStencil.Text

---@class FOXStencil.Layers
---@field text FOXStencil.Text.Generator

---@class FOXStencil.Text: FOXStencil.Layer
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Text.Styles
local default = {
	---@type string
	text = "",

	---@type Vector2
	pos = vec(0, 0),
	---@type number
	size = 9,
	---@type number
	width = 0,
	---@type "CENTER"|"LEFT"|"RIGHT"
	align = "LEFT",

	---@type Vector3
	outline = vectors.intToRGB(0x202020),
	---@type boolean
	outline_state = false,
	---@type boolean
	shadow = false,

	---@type boolean
	visible = true
}

---Redraws this text
---@param self FOXStencil.Text
local function draw(self)
	local styles = self.styles

	local size = styles.size / 9

	local visible = styles.text ~= "" and styles.visible

	if visible then
		self.task
			:text(styles.text)
			:width(styles.width / size)
			:alignment(styles.align)

			:pos(-styles.pos:augmented(1 / 16))
			:scale(size)

			:setOutline(styles.outline_state)
			:outlineColor(styles.outline)
			:shadow(styles.shadow)
	end

	self.task:visible(visible)
end

local copy = require("./../core/parser").copy

---Sets the given styles
---@param styles FOXStencil.Text.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.styles) then
		draw(self)
	end

	return self
end

---@param part ModelPart
return function(part)
	---@class FOXStencil.Text
	local self = {
		task = part:newText("text-" .. math.random()):light(15),
		styles = setmetatable({}, { __index = default }),
	}

	return setmetatable(self, obj)
end
