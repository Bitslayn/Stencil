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
---@param str string
---@return string
local function emoji_fix(str)
	str = str:gsub(":[^:]+:", "  ")
	return str
end

function obj:draw()
	local props = self.elem.props

	local label_size = client.getTextDimensions(emoji_fix(props.label), props.live_size.x) * props.label_size
	local label_w, label_h = unpack2(label_size)
	local x = -props.tex_extend[4] + math.lerp(0, props.live_size.x - label_w, 0.5)
	local y = -props.tex_extend[1] + math.lerp(0, props.live_size.y - label_h, 0.5)

	local task = self.text
		:pos(-x, -y)
		:scale(props.label_size)
		:width(props.live_size[1])
		:visible(props.label ~= "")

		-- TODO separate into run-on-call method
		:text(props.label)
		:shadow(props.label_shadow)
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
