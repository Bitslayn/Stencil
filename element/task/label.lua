---@class Stencil.Elements.Label
---@field text TextTask
---@field id string
---@field parn Stencil.Element
local obj = {}
obj.__index = obj

local translate4 = matrices.translate4
local scale4 = matrices.scale4

local vec2 = vectors.vec2
local unpack2 = vec2().unpack
local tostring = tostring
local concat = table.concat

function obj:draw()
	local stat = self.parn.stat
	
	local id = concat({
		concat({ unpack2(stat.pos) }),
		concat({ unpack2(stat.size) }),
	})
	if self.id == id then return end
	self.id = id

	local styl = self.parn.styl

	local task = self.text
		:width(stat.size[1])
		:visible(styl.label.text ~= "")

		-- TODO separate into run-on-call method
		:text(styl.label.text)
end

---Creates a label that can be stylized later
---@param parn Stencil.Element
---@return Stencil.Elements.Label
return function(parn)
	local self = setmetatable({
		text = parn.part:newText("label"):pos(0, 0, -1):light(15),
		id = "",
		parn = parn,
	}, obj)

	return self
end
