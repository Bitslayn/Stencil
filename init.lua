---@class FOXStencil
local api = {}

local layout = require("./render/layout")

---@class FOXStencil.Styles
---@field pos Vector2?
---@field size Vector2?
---@field mode [FOXStencil.Enum.Mode, FOXStencil.Enum.Mode]?
---@field scale Vector2?

---@alias FOXStencil.Enum.Mode
---| "fixed"
---| "FIXED"
---| "grow"
---| "GROW"

---@alias FOXStencil.Enum.Direction
---| "x"
---| "hor"
---| "horizontal"
---| "HORIZONTAL"
---| "y"
---| "ver"
---| "vertical"
---| "VERTICAL"

---@class FOXStencil.Element
---@field type string
---@field styl FOXStencil.Styles
---@field chld FOXStencil.Element[]
local element = {}
---@protected
element.__index = element

---@alias FOXStencil.Element.Any FOXStencil.Element|FOXStencil.Element.Box|FOXStencil.Element.Outline|FOXStencil.Element.Slice|FOXStencil.Element.Text
---@alias FOXStencil.Styles.Any FOXStencil.Styles|FOXStencil.Styles.Box|FOXStencil.Styles.Outline|FOXStencil.Styles.Slice|FOXStencil.Styles.Text

---@class FOXStencil.Element.Container: FOXStencil.Element.Box
---@class FOXStencil.Styles.Container: FOXStencil.Styles.Box

---Creates a new container
---@param styles FOXStencil.Styles.Container?
---@return FOXStencil.Element.Container
function api.new(styles)
	styles = styles or {}

	styles.pos = styles.pos or vectors.vec2()
	styles.size = styles.size or vectors.vec2()
	styles.mode = styles.mode or { "f", "f" }
	styles.scale = styles.scale or vec(1, 1)

	styles.pad = styles.pad or vectors.vec2()
	styles.gap = styles.gap or 0
	styles.dir = styles.dir or "hor"

	styles.color = styles.color or vectors.vec4()

	local elem = { type = "box", styl = styles, chld = {} }
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Container]]
end

---@class FOXStencil.Element.Box: FOXStencil.Element
---@field styl FOXStencil.Styles.Box
---@class FOXStencil.Styles.Box: FOXStencil.Styles
---@field pad Vector2? Margin around children
---@field gap number? Margin between children
---@field dir FOXStencil.Enum.Direction?
---@field color Vector4?

---Creates a new box
---@param styles FOXStencil.Styles.Box
---@return FOXStencil.Element.Box
function element:box(styles)
	styles.pos = styles.pos or vectors.vec2()
	styles.size = styles.size or vectors.vec2()
	styles.mode = styles.mode or { "f", "f" }
	styles.scale = styles.scale or vec(1, 1)

	styles.pad = styles.pad or vectors.vec2()
	styles.gap = styles.gap or 0
	styles.dir = styles.dir or "hor"

	styles.color = styles.color or vectors.vec4()

	local elem = { type = "box", styl = styles, chld = {} }
	table.insert(self.chld, elem)
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Box]]
end

---@class FOXStencil.Element.Outline: FOXStencil.Element
---@field styl FOXStencil.Styles.Outline
---@class FOXStencil.Styles.Outline: FOXStencil.Styles
---@field pad Vector2? Margin around children
---@field gap number? Margin between children
---@field dir FOXStencil.Enum.Direction?
---@field color Vector4?
---@field weight number?

---Creates a new outline
---@param styles FOXStencil.Styles.Outline
---@return FOXStencil.Element.Outline
function element:outline(styles)
	styles.pos = styles.pos or vectors.vec2()
	styles.size = styles.size or vectors.vec2()
	styles.mode = styles.mode or { "f", "f" }
	styles.scale = styles.scale or vec(1, 1)

	styles.pad = styles.pad or vectors.vec2()
	styles.gap = styles.gap or 0
	styles.dir = styles.dir or "hor"

	styles.color = styles.color or vectors.vec4()
	styles.weight = styles.weight or 1

	local elem = { type = "outline", styl = styles, chld = {} }
	table.insert(self.chld, elem)
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Outline]]
end

---@class FOXStencil.Element.Slice: FOXStencil.Element
---@field styl FOXStencil.Styles.Slice
---@class FOXStencil.Styles.Slice: FOXStencil.Styles
---@field pad Vector2? Margin around children
---@field gap number? Margin between children
---@field dir FOXStencil.Enum.Direction?
---@field slice Vector4?
---@field map_uv Vector2?
---@field map_region Vector2?
---@field texture Texture

---Creates a new 9 slice
---@param styles FOXStencil.Styles.Slice
---@return FOXStencil.Element.Slice
function element:slice(styles)
	styles.pos = styles.pos or vectors.vec2()
	styles.size = styles.size or vectors.vec2()
	styles.mode = styles.mode or { "f", "f" }
	styles.scale = styles.scale or vec(1, 1)

	styles.pad = styles.pad or vectors.vec2()
	styles.gap = styles.gap or 0
	styles.dir = styles.dir or "hor"

	styles.slice = styles.slice or vectors.vec4()
	styles.map_uv = styles.map_uv or vectors.vec2()
	styles.map_region = styles.map_region or vectors.vec2()
	assert(styles.texture)

	local elem = { type = "slice", styl = styles, chld = {} }
	table.insert(self.chld, elem)
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Slice]]
end

---@class FOXStencil.Element.Text: FOXStencil.Element
---@field styl FOXStencil.Styles.Text
---@class FOXStencil.Styles.Text: FOXStencil.Styles
---@field text string?
---@field outline Vector3?

---Creates a new text label
---@param styles FOXStencil.Styles.Text
---@return FOXStencil.Element.Text
function element:text(styles)
	styles.pos = styles.pos or vectors.vec2()
	styles.size = styles.size or vectors.vec2()
	styles.mode = styles.mode or { "f", "f" }
	styles.scale = styles.scale or vec(1, 1)

	styles.pad = styles.pad or vectors.vec2()
	styles.gap = styles.gap or 0
	styles.dir = styles.dir or 1

	styles.text = styles.text or ""

	local elem = { type = "text", styl = styles, chld = {} }
	table.insert(self.chld, elem)
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Text]]
end

---Draws this element to a ModelPart
---@generic self
---@param self self
---@param part ModelPart
---@return self
function element:draw(part)
	layout.size(self)
	layout.grow(self)
	layout.position(self)
	layout.draw(self, part)

	return self
end

return api
