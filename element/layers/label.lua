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

function obj:draw()
	local props = self.elem.props

	local label_w, label_h = unpack2(client.getTextDimensions(props.label) - vec(0, 1))
	local x = -props.tex_extend[4] + math.lerp(0, props.live_size.x - label_w, 0.5)
	local y = -props.tex_extend[1] + math.lerp(0, props.live_size.y - label_h, 0.5)

	local task = self.text
		:pos(-x, -y)
		:width(props.live_size[1])
		:visible(props.label ~= "")

		-- TODO separate into run-on-call method
		:text(props.label)
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
