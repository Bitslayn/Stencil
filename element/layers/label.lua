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
	local task = self.text
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
