---@class FOXStencil.Layout
local class = {}
---@package
class.__index = class

---@param part ModelPart
---@return FOXStencil.Layout
local function new(part)
	---@class FOXStencil.Layout
	local self = {
		part = part:newPart("root"):scale(1, 1, 0.2),
		chld = require("../element/map")() --[[@as FOXMap<integer, FOXStencil.Element>]],
	}
	return setmetatable(self, class)
end

---@param props FOXStencil.Element.Props?
---@return FOXStencil.Element
function class:newElement(props)
	local elem = require("../element/class")(self.part:newPart("elem"), self, nil, self.chld):setProps(props)
	self.chld:push(elem)
	return elem
end

local layout = require("./render/layout")
local interact = require("./render/interact")

-- ---@param pos Vector3
-- ---@param planeDir Vector3
-- ---@param planePos Vector3
-- ---@return Vector3
-- local function ray2Plane(pos, planePos, planeDir)
-- 	local pdn = planeDir:normalized()
-- 	local dtp = pdn:dot(planePos - pos)
-- 	return pos + pdn * dtp
-- end

---@return self
function class:draw()
	local mat = self.part:partToWorldMatrix()

	for i = 1, #self.chld do
		local elem = self.chld[i]
		layout.restore(elem)

		layout.size(elem, 1)
		layout.grow(elem, 1)
		layout.size(elem, 2)
		layout.grow(elem, 2)
		layout.position(elem)

		layout.draw(elem, 0, 1)
		
		if mat == matrices.scale4(1 / 16) then
			interact.screen_hover(elem)
		else
			interact.world_hover(elem)
	
			-- local cam = client.getCameraPos()
			-- local poi = ray2Plane(cam, mat:apply(), mat:applyDir(0, 0, -1))
			-- self.part:scale(1, 1, math.abs((poi - cam):dot(mat:applyDir(0, 0, 1):normalize() * 0.5))) -- Fixes bug when traveling through x/z = 0
		end
	end


	return self
end

return new
