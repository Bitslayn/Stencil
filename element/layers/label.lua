---@class FOXStencil.Element.Label
---@field text TextTask
---@field elem FOXStencil.Element
local obj = {}
obj.__index = obj

local translate4 = matrices.translate4
local scale4 = matrices.scale4

local vec2 = vectors.vec2
local unpack2 = vec2().unpack
local tostring = tostring
local concat = table.concat

---Fixes emojis on <0.1.6
---@param str string|number
---@return string
local function emoji_fix(str)
	str = string.gsub(str, ":[^:]+:", "  ")
	return str
end

function obj:draw()
	local props = self.elem:getProps()
	local state = self.elem.state

	local label_size = client.getTextDimensions(emoji_fix(props.label), state.size.x) * props.label_size
	local label_w, label_h = unpack2(label_size)
	local x = -props.tex_extend[4] + math.lerp(0, state.size.x - label_w, 0.5)
	local y = -props.tex_extend[1] + math.lerp(0, state.size.y - label_h, 0.5)

	self.text
		:pos(-x, -y, -0.5)
		:scale(props.label_size)
		:width(state.size.x)
		:visible(props.label ~= "")

	-- TODO separate into run-on-call method
		:text(props.label)
		:shadow(props.label_shadow)
		:outline(props.label_outline)
		:outlineColor(props.label_outline_color)
end

---Creates a label that can be stylized later
---@param elem FOXStencil.Element
---@return FOXStencil.Element.Label
return function(elem)
	local self = setmetatable({
		text = elem.part:newText("label"):pos(0, 0, -1):light(15),
		elem = elem,
	}, obj)

	return self
end
