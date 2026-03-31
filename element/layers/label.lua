---@class Stencil.Elements.Label
---@field [1] TextTask
---@field parn Stencil.Element
local obj = {}
obj.__index = obj

local newText = models.newText

local __index = figuraMetatables.TextTask.__index
local text = __index.text
local width = __index.width

local translate4 = matrices.translate4
local scale4 = matrices.scale4

local vec2 = vectors.vec2
local unpack = vec2().unpack

function obj:update()
	local styl = self.parn.styl
	local stat = self.parn.stat

	local task = self[1]
	text(task, styl.label.text)
	width(task, stat.size[1])
end

---Creates a label that can be stylized later
---@param parn Stencil.Element
---@return Stencil.Elements.Label
return function(parn)
	local self = setmetatable({ parn = parn }, obj)

	local task = newText(parn.part, "label")
	self[1] = task

	return self
end
