---Generates a label layer
---
---Call :setStyles() with a table to change the styles
---@alias FOXStencil.Label.Generator fun(part: ModelPart): FOXStencil.Label

---@class FOXStencil.Layers
---@field label FOXStencil.Label.Generator

---@class FOXStencil.Label: FOXStencil.Layer
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Label.Styles
local default = {
	---@type string
	text = "",

	---@type Vector2
	pos = vec(0, 0),
	---@type number
	size = 9,
	---@type number
	width = 0,
	---@type boolean
	wrap = true,
	---@type "CENTER"|"LEFT"|"RIGHT"
	alignment = "LEFT",

	---@type Vector3
	outline = vectors.intToRGB(0x202020),
	---@type boolean
	outline_state = false,
	---@type boolean
	shadow = false,
}

---Redraws this label
---@param self FOXStencil.Label
local function draw(self)
	local styles = self.styles

	local size = styles.size / 9

	local visible = styles.text ~= ""

	if visible then
		self.task
			:text(styles.text)
			:width(styles.width / size)
			:alignment(styles.alignment)

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
---@param styles FOXStencil.Label.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.styles) then
		draw(self)
	end

	return self
end

return function(part)
	---@class FOXStencil.Label
	local self = {
		task = part:newText("label-" .. math.random())
			:light(15),
		styles = setmetatable({}, { __index = default }),
	}

	return setmetatable(self, obj)
end
