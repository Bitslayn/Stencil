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
		chld = require("../element/map")() --[[@as FOXMap<integer, FOXStencil.Element>]],
	}
	return setmetatable(self, class)
end

---@param props FOXStencil.Element.Props?
---@return FOXStencil.Element
function class:newElement(props)
	local elem = require("../element/class")(self.part:newPart("elem"), self):setProps(props)
	self.chld:push(elem)
	return elem
end

local layout = require("./render/layout")

function class:draw()
	-- local mat = self.part:partToWorldMatrix()
	-- if mat == matrices.scale4(1 / 16) then
	-- 	self:screenHover()
	-- else
	-- 	local cam = client.getCameraPos()
	-- 	local poi = ray2Plane(cam, mat:apply(), mat:applyDir(0, 0, -1))
	-- 	self.part:scale(1, 1, (cam - poi):length() / 8)

	-- 	self:worldHover()
	-- end

	
	for i = 1, #self.chld do
		local elem = self.chld[i]
		layout.restore(elem)

		layout.size(elem, 1)
		layout.grow(elem, 1)
		layout.wrap(elem)
		layout.size(elem, 2)
		layout.grow(elem, 2)
		layout.position(elem)
	
		layout.draw(elem, 0, 1)
	end
end

return new
