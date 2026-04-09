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

---Returns the element being moused over
---
---A position relative to the current element must be given
---@param pos Vector2?
---@return self
function class:hover(pos)
	for i = 1, #self.chld do
		local elem = self.chld[i]
		layout.hover(elem, pos)
	end
	return self
end

-- TODO Move alternate hover functions to user space or something

---Returns the screen element being moused over
function class:screenHover()
	local pos = client.getMousePos() / client.getGuiScale()
	return self:hover(pos)
end

local EPSILON = 2.2204460492503131e-16
local abs = math.abs
local dot = vectors.vec3().dot

---@param ray_pos Vector3
---@param ray_dir Vector3
---@param plane_pos Vector3
---@param plane_normal Vector3
---@return Vector3? intersection_point
local function intersectPlane(ray_pos, ray_dir, plane_pos, plane_normal)
	local denom = dot(plane_normal, ray_dir)
	if -denom < EPSILON then return end
	local d = plane_pos - ray_pos
	local t = dot(d, plane_normal) / denom
	if t < EPSILON then return end
	return ray_pos + ray_dir * t
end

---@param hit_pos Vector3
---@param plane_mat Matrix4
---@return Vector3
local function worldToLocal(hit_pos, plane_mat)
	local pos_mat = matrices.translate4(plane_mat:apply())
	local rot_mat = matrices.rotation4(0, 180, 0) * (pos_mat:inverted() * plane_mat):inverted()

	return (rot_mat * matrices.translate4(hit_pos - plane_mat:apply())):apply()
end

---Returns the world element being moused over
function class:worldHover()
	local mat = self.part:partToWorldMatrix()

	local pos_mat = matrices.translate4(mat:apply())
	local rot_mat = matrices.rotation4(0, 180, 0) * (pos_mat:inverted() * mat):inverted()

	local hit = intersectPlane(
		client.getCameraPos(),
		client.getCameraDir(),
		mat:apply(),
		mat:applyDir(0, 0, -1)
	)

	return self:hover(hit and worldToLocal(hit, mat).xy * vec(1, -1))
end

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
	if mat == matrices.scale4(1 / 16) then
		self:screenHover()
	else
		self:worldHover()

		-- local cam = client.getCameraPos()
		-- local poi = ray2Plane(cam, mat:apply(), mat:applyDir(0, 0, -1))
		-- self.part:scale(1, 1, math.abs((poi - cam):dot(mat:applyDir(0, 0, 1):normalize() * 0.5))) -- Fixes bug when traveling through x/z = 0
	end

	for i = 1, #self.chld do
		local elem = self.chld[i]
		layout.restore(elem)

		layout.size(elem, 1)
		layout.grow(elem, 1)
		layout.size(elem, 2)
		layout.grow(elem, 2)
		layout.position(elem)

		layout.draw(elem, 0, 1)
	end

	return self
end

return new
