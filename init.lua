---@class FOXStencil
local api = {}

---@alias FOXStencil.Sizing.Mode
---| "fit"
---| "FIT"
---| "grow"
---| "GROW"

---@class FOXStencil.Sizing.Property
---@field mode FOXStencil.Sizing.Mode?
---@field min number?
---@field max number?

---@alias FOXStencil.Sizing [FOXStencil.Sizing.Property?, FOXStencil.Sizing.Property?]

---@class FOXStencil.Styles.Common
---@field pos Vector2?
---@field size Vector2?
---@field sizing FOXStencil.Sizing?
---@field scale Vector2?
---@field part ModelPart?

---@alias FOXStencil.Direction
---| "x"
---| "hor"
---| "horizontal"
---| "HORIZONTAL"
---| "y"
---| "ver"
---| "vertical"
---| "VERTICAL"

---@class FOXStencil.Styles.Container
---@field pad Vector4? Margin around children
---@field gap number? Margin between children
---@field dir FOXStencil.Direction?
---@field align Vector2?
---@field justify number?

---@class FOXStencil.Element
---@field type string
---@field styl FOXStencil.Styles.Any
---@field parn FOXStencil.Element.Any?
---@field chld FOXStencil.Element.Any[]?
local element = {}
---@protected
element.__index = element

---@alias FOXStencil.Element.Any
---| FOXStencil.Element.Box
---| FOXStencil.Element.Label
---| FOXStencil.Element.Sprite
---| FOXStencil.Element.Part
---| FOXStencil.Element.Task
---@alias FOXStencil.Styles.Any
---| FOXStencil.Styles.Box
---| FOXStencil.Styles.Label
---| FOXStencil.Styles.Sprite
---| FOXStencil.Styles.Part
---| FOXStencil.Styles.Task

---Creates an empty element
---@param id string
---@param styl FOXStencil.Styles.Any?
---@param chld table?
---@param parn FOXStencil.Element?
---@return FOXStencil.Element
local function new(id, styl, chld, parn)
	-- Create the element

	local elem = setmetatable({
		type = id,
		styl = {
			-- Common

			pos = vectors.vec2(),
			sizing = {
				{ mode = "FIT", min = 0, max = math.huge },
				{ mode = "FIT", min = 0, max = math.huge },
			},
			size = vectors.vec2(),
			scale = vec(1, 1),

			-- Container

			pad = vectors.vec4(),
			gap = 0,
			dir = "hor",
			align = vectors.vec2(),
			justify = 0,
		},
		chld = chld,
		parn = parn,
	}, element)

	-- Ingest styles

	if type(styl) == "table" then
		---Merges two tables
		---
		---Table a's contents are read and written into table b
		---@param a table
		---@param b table
		local function merge(a, b)
			for k, v in next, a do
				if type(v) == "table" and type(b[k]) == "table" then
					merge(a[k], b[k])
				else
					b[k] = v
				end
			end
		end
		merge(styl, elem.styl)
	end

	-- Add element to parent

	if parn then
		table.insert(parn.chld, elem)
	end

	return elem
end

---@class FOXStencil.Texture
---@field atlas Texture
---@field pos Vector2?
---@field size Vector2?
---@field slice Vector4?
---@field color Vector3|Vector4?
---@field extend Vector4?

---@class FOXStencil.Element.Box: FOXStencil.Element
---@field styl FOXStencil.Styles.Box
---@class FOXStencil.Styles.Box: FOXStencil.Styles.Common, FOXStencil.Styles.Container
---@field texture FOXStencil.Texture?
---@field line_color Vector3|Vector4?
---@field line_weight number?

---Creates a new box
---@param styl FOXStencil.Styles.Box?
---@return FOXStencil.Element.Box
function api.new(styl)
	styl = styl or {}

	styl.line_color = styl.line_color or vectors.vec4()
	styl.line_weight = styl.line_weight or 1

	styl.texture = styl.texture or {}
	styl.texture.pos = styl.texture.pos or vectors.vec2()
	styl.texture.size = styl.texture.size or styl.texture.atlas and styl.texture.atlas:getDimensions() or vec(1, 1)
	styl.texture.slice = styl.texture.slice or vectors.vec4()
	styl.texture.color = styl.texture.color or vectors.vec4()
	styl.texture.extend = styl.texture.extend or vectors.vec4()

	return new("box", styl, {}) --[[@as FOXStencil.Element.Box]]
end

---Creates a new box
---@param styl FOXStencil.Styles.Box
---@return FOXStencil.Element.Box
function element:box(styl)
	styl = styl or {}

	styl.line_color = styl.line_color or vectors.vec4()
	styl.line_weight = styl.line_weight or 1

	styl.texture = styl.texture or {}
	styl.texture.pos = styl.texture.pos or vectors.vec2()
	styl.texture.size = styl.texture.size or styl.texture.atlas and styl.texture.atlas:getDimensions() or vec(1, 1)
	styl.texture.slice = styl.texture.slice or vectors.vec4()
	styl.texture.color = styl.texture.color or vec(1, 1, 1)
	styl.texture.extend = styl.texture.extend or vectors.vec4()

	return new("box", styl, {}, self) --[[@as FOXStencil.Element.Box]]
end

---@class FOXStencil.Element.Label: FOXStencil.Element
---@field styl FOXStencil.Styles.Label
---@class FOXStencil.Styles.Label: FOXStencil.Styles.Common
---@field text string?
---@field outline Vector3?

---Creates a new text label
---@param styl FOXStencil.Styles.Label
---@return FOXStencil.Element.Label
function element:label(styl)
	styl = styl or {}

	styl.text = styl.text or ""

	styl.size = styl.size or vectors.vec2()
	for w in string.gmatch(styl.text, "[^%s]+") do
		local size = client.getTextDimensions(w)
		styl.size = styl.size.x < size.x and size or styl.size
	end

	styl.sizing = styl.sizing or {}
	styl.sizing[1] = styl.sizing[1] or {}
	styl.sizing[1].mode = styl.sizing[1].mode or "GROW"

	return new("label", styl, nil, self) --[[@as FOXStencil.Element.Label]]
end

---@class FOXStencil.Element.Sprite: FOXStencil.Element
---@field styl FOXStencil.Styles.Sprite
---@class FOXStencil.Styles.Sprite: FOXStencil.Styles.Common
---@field texture Texture

---Creates a new sprite
---@param styl FOXStencil.Styles.Sprite
---@return FOXStencil.Element.Sprite
function element:sprite(styl)
	styl.sizing = styl.sizing or {}
	styl.sizing[1] = styl.sizing[1] or {}
	styl.sizing[1].mode = styl.sizing[1].mode or "GROW"

	return new("sprite", styl, nil, self) --[[@as FOXStencil.Element.Sprite]]
end

---@class FOXStencil.Element.Part: FOXStencil.Element
---@field styl FOXStencil.Styles.Part
---@class FOXStencil.Styles.Part: FOXStencil.Styles.Common
---@field part ModelPart

---Creates a new ModelPart
---@param styl FOXStencil.Styles.Part
---@return FOXStencil.Element.Part
function element:part(styl)
	return new("part", styl, nil, self) --[[@as FOXStencil.Element.Part]]
end

---@class FOXStencil.Element.Task: FOXStencil.Element
---@field styl FOXStencil.Styles.Task
---@class FOXStencil.Styles.Task: FOXStencil.Styles.Common
---@field task RenderTask

---Creates a new RenderTask
---@param styl FOXStencil.Styles.Task
---@return FOXStencil.Element.Task
function element:task(styl)
	return new("task", styl, nil, self) --[[@as FOXStencil.Element.Task]]
end

local layout = require("./render/layout")

---Draws this element to a ModelPart
---@generic self
---@param self self
---@param part ModelPart
---@return self
function element:draw(part)
	layout.size(self, 1)
	layout.grow(self, 1)
	layout.wrap(self)
	layout.size(self, 2)
	layout.grow(self, 2)
	layout.position(self)
	layout.draw(self, part)

	return self
end

---Returns the element being moused over
---
---A position relative to the current element must be given
---@generic self
---@param self self
---@param pos Vector2
---@return FOXStencil.Element.Any?
function element:hover(pos)
	return layout.hover(self, pos)
end

---Returns the screen element being moused over
---@return FOXStencil.Element.Any?
function element:screenHover()
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
---@return FOXStencil.Element.Any?
function element:worldHover()
	local mat = self.styl.part:partToWorldMatrix()

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
