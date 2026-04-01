---@class Stencil
local api = {}

---@alias Stencil.Direction
---| "x"
---| "hor"
---| "horizontal"
---| "HORIZONTAL"
---| "y"
---| "ver"
---| "vertical"
---| "VERTICAL"

---@alias Stencil.Styles.Pos Vector2
---@alias Stencil.Styles.Size Vector2
---@alias Stencil.Styles.Scale number|Vector2
---@alias Stencil.Styles.Margin number|Vector2|Vector3|Vector4
---@alias Stencil.Styles.Border number|Vector2|Vector3|Vector4
---@alias Stencil.Styles.Dir Stencil.Direction
---@alias Stencil.Styles.Padding number|Vector2|Vector3|Vector4
---@alias Stencil.Styles.Gap number
---@alias Stencil.Styles.Justify number
---@alias Stencil.Styles.Align number|Vector2
---@alias Stencil.Styles.Color Vector3|Vector4
---@alias Stencil.Styles.Label string
---@alias Stencil.Styles.Texture Texture

---@class Stencil.Styles
---@field pos Stencil.Styles.Pos?
---@field size Stencil.Styles.Size?
---@field scale Stencil.Styles.Scale?
---@field margin Stencil.Styles.Margin?
---@field border Stencil.Styles.Border?
---@field dir Stencil.Styles.Dir?
---@field padding Stencil.Styles.Padding?
---@field gap Stencil.Styles.Gap?
---@field justify Stencil.Styles.Justify?
---@field align Stencil.Styles.Align?
---@field color Stencil.Styles.Color?
---@field label Stencil.Styles.Label?
---@field texture Stencil.Styles.Texture?

---@class Stencil.State.Size
---@field [number] {mode: "FIT"|"GROW", min: number, max: number, val: number}
---@class Stencil.State.Border
---@field weight number
---@field color Vector3|Vector4
---@class Stencil.State.Label
---@field text string
---@field color Vector3|Vector4
---@field align "LEFT"|"CENTER"|"RIGHT"
---@class Stencil.State.Texture
---@field atlas Texture
---@field pos Vector2
---@field size Vector2
---@field slice Vector4
---@field extend Vector4

---@class Stencil.Styles.Internal
---@field pos Vector2
---@field size Stencil.State.Size
---@field scale number|Vector2
---@field margin Vector4
---@field border Stencil.State.Border[]
---@field dir Stencil.Direction
---@field padding Vector4
---@field gap number
---@field justify number
---@field align Vector2
---@field color Vector3|Vector4
---@field label Stencil.State.Label
---@field texture Stencil.State.Texture

---@class Stencil.State
---@field pos Vector2
---@field size Vector2
---@field size_min Vector2
---@field size_max Vector2

---@class Stencil.Screen: Stencil.Element
---@field chld Stencil.Element[]
---@field styl Stencil.Styles
---@field stat Stencil.State
---@field part ModelPart
local screen = {}
---@package
screen.__index = screen

---@param part ModelPart
---@return Stencil.Screen
function api.newScreen(part)
	local self = setmetatable({
		chld = {},
		styl = {
			pos = vec(0, 0),
			padding = vectors.vec4(),
			dir = "x",
			size = {
				{ mode = "FIT", min = 0, max = math.huge, val = 0 },
				{ mode = "FIT", min = 0, max = math.huge, val = 0 },
			},
			gap = 0,
			justify = 0,
			align = vec(0, 0),
		},
		part = part,
		debt = 0,
	}, screen)
	self.root = self
	return self
end

---@class Stencil.Element
---@field chld Stencil.Element[]
---@field parn Stencil.Element|Stencil.Screen
---@field root Stencil.Screen
---@field styl Stencil.Styles.Internal
---@field stat Stencil.State
---@field part ModelPart
---@field elem Stencil.Elements
local element = {}
---@package
element.__index = element

local elem = require("./element/class")

---Creates a new element with the given styles
---@param self Stencil.Element|Stencil.Screen
---@param styl Stencil.Styles
---@return Stencil.Element
local function newElement(self, styl)
	local part = self.part:newPart("elem")
	local new = setmetatable({
		chld = {},
		parn = self,
		root = self.root,
		styl = styl,
		stat = {},
		part = part,
	}, element)
	new.elem = elem(new)
	self.chld[#self.chld + 1] = new
	return new
end

screen.newElement = newElement
element.newElement = newElement

---Removes this element from its parent
function element:remove()
	self.parn = nil --TODO ACTUALLY remove child from parent
end

local layout = require("./render/layout")

---@param pos Vector3
---@param planeDir Vector3
---@param planePos Vector3
---@return Vector3
local function ray2Plane(pos, planePos, planeDir)
	local pdn = planeDir:normalized()
	local dtp = pdn:dot(planePos - pos)
	return pos + pdn * dtp
end

---Draws this element to a ModelPart
---@return self
function screen:draw()
	local cam = client.getCameraPos()
	local mat = self.part:partToWorldMatrix()
	local poi = ray2Plane(cam, mat:apply(), mat:applyDir(0, 0, -1))
	self.part:scale(1, 1, (cam - poi):length() * 0.02)

	-- local t = client.getSystemTime()
	layout.restore(self)

	layout.size(self, 1)
	layout.grow(self, 1)
	layout.wrap(self)
	layout.size(self, 2)
	layout.grow(self, 2)
	layout.position(self)

	layout.draw(self, 0, 1)
	-- host:actionbar(client.getSystemTime() - t .. "ms")

	return self
end

---Merges tables and does surface level scrubbing
---@param a table
---@param b table?
---@return table
local function merge(a, b)
	if type(b) ~= "table" then return a end
	for k, v in next, b do
		if type(a[k]) == type(v) then
			a[k] = v
		end
	end
	return a
end

---@param x number|{mode: "FIT"|"GROW", min: number, max: number, val: number}?
---@param y number|{mode: "FIT"|"GROW", min: number, max: number, val: number}?
---@return Stencil.Styles.Size
function api.size(x, y)
	local vars = { x, y }

	for i = 1, #vars do
		-- Accepts numbers as default weight value

		local v = vars[i]
		if type(v) == "number" then
			v = { val = v }
		end

		-- Merge function will throw away non-tables and illegal arguments

		vars[i] = merge({
			mode = "FIT",
			min = 0,
			max = math.huge,
			val = 0,
		}, v)
	end

	---@diagnostic disable-next-line: return-type-mismatch
	return vars
end

---@param t number|{weight: number, color: Vector4}
---@param r number|{weight: number, color: Vector4}
---@param b number|{weight: number, color: Vector4}
---@param l number|{weight: number, color: Vector4}
---@return Stencil.Styles.Border
function api.border(t, r, b, l)
	local vars = { t, r, b, l }

	for i = 1, #vars do
		-- Accepts numbers as default weight value

		local v = vars[i]
		if type(v) == "number" then
			v = { weight = v }
		end

		-- Merge function will throw away non-tables and illegal arguments

		vars[i] = merge({
			weight = 0,
			color = vec(0, 0, 0, 0),
		}, v)
	end

	---@diagnostic disable-next-line: return-type-mismatch
	return vars
end

---@param t {text: string, color: Vector4, align: "LEFT"|"CENTER"|"RIGHT"}
---@return Stencil.Styles.Label
function api.label(t)
	-- Merge function will throw away non-tables and illegal arguments

	---@diagnostic disable-next-line: return-type-mismatch
	return merge({
		text = "",
		color = vec(0, 0, 0, 1),
		align = "LEFT",
	}, t)
end

---@param t {atlas: Texture, pos: Vector2, size: Vector2, slice: Vector4, extend: Vector4}
---@return Stencil.Styles.Texture
function api.texture(t)
	-- Merge function will throw away non-tables and illegal arguments

	---@diagnostic disable-next-line: return-type-mismatch
	return merge({
		atlas = textures["FOXStencil_blank"],
		pos = vec(0, 0),
		size = vec(0, 0),
		slice = vec(0, 0, 0, 0),
		extend = vec(0, 0, 0, 0),
	}, t)
end

---Returns the element being moused over
---
---A position relative to the current element must be given
---@generic self
---@param self self
---@param pos Vector2
---@return Stencil.Element?
function screen:hover(pos)
	return layout.hover(self, pos)
end

---Returns the screen element being moused over
---@return Stencil.Element?
function screen:screenHover()
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
	if abs(denom) < EPSILON then return end
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
---@return Stencil.Element?
function screen:worldHover()
	local mat = self.part:partToWorldMatrix()

	local pos_mat = matrices.translate4(mat:apply())
	local rot_mat = matrices.rotation4(0, 180, 0) * (pos_mat:inverted() * mat):inverted()

	local hit = intersectPlane(
		client.getCameraPos(),
		client.getCameraDir(),
		mat:apply(),
		mat:applyDir(0, 0, -1)
	)

	if not hit then return end

	local pos = worldToLocal(hit, mat).xy * vec(1, -1)

	return self:hover(pos)
end

return api
