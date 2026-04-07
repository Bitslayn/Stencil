---@class FOXStencil.Layout
local class = {}
---@package
class.__index = class

---@param part ModelPart
---@return FOXStencil.Layout
local function new(part)
	---@class FOXStencil.Layout
	local self = {
		part = part,
		elem = require("../element/map")() --[[@as FOXMap<integer, FOXStencil.Element>]],
	}
	return setmetatable(self, class)
end

---@param props FOXStencil.Element.Props?
---@return FOXStencil.Element
function class:newElement(props)
	return require("../element/class")(self.part:newPart("elem"), self):setProps(props)
end

return new
