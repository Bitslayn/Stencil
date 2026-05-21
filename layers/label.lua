---@class FOXStencil.Label
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Label.Styles
local default = {
	---@type string
	text = "",
	---@type Vector3|Vector4
	color = vec(1, 1, 1, 1),

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

	---@type Vector3|Vector4
	outline = vec(0, 0, 0, 0),
	---@type boolean
	shadow = false
}
---@package
default.__index = default

---Redraws this label
---@param self FOXStencil.Label
local function draw(self)
	local styles = self.styles

	local size = styles.size / 9

	self.task
		:text(styles.text)
		:width(styles.width / size)
		:alignment(styles.alignment)

		:pos(-styles.pos:augmented(1 / 16))
		:scale(size)

		:setOutline(styles.outline.a ~= 0)
		:outlineColor(styles.outline.xyz)
		:shadow(styles.shadow)
end

---@generic v
---@type table<type, fun(v: v): v>
local copy = {
	Vector2 = function(v) return v:copy() end,
	Vector3 = function(v) return v:copy() end,
	Vector4 = function(v) return v:copy() end,
	string = function(v) return v end,
	number = function(v) return v end,
	boolean = function(v) return v end,
}

---Sets the given styles
---@param styles FOXStencil.Label.Styles
---@return self
function obj:setStyles(styles)
	local diff = false

	for k, v in next, styles do
		if self.styles[k] ~= v then
			self.styles[k] = copy[type(v)](v)
			diff = true
		end
	end

	if diff then
		draw(self)
	end

	return self
end

---Generates a label layer
---
---Call :setStyles() with a table to change the styles
---@param part ModelPart
---@return FOXStencil.Label
return function(part)
	---@class FOXStencil.Label
	local self = {
		task = part:newText("label-" .. math.random()):light(15),
		styles = setmetatable({}, { __index = default }),
	}

	return setmetatable(self, obj)
end
