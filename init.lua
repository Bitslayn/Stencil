---@class FOXStencil
local api = {}

local layout = require("./render/layout")

-- TODO FIX THIS MESS AAAAAAAAA

---@alias FOXStencil.Common.Sizing.Mode
---| "fit"
---| "FIT"
---| "grow"
---| "GROW"

---@class FOXStencil.Common.Sizing.Property
---@field mode FOXStencil.Common.Sizing.Mode
---@field min number
---@field max number

---@alias FOXStencil.Common.Sizing [FOXStencil.Common.Sizing.Property, FOXStencil.Common.Sizing.Property]

---@class FOXStencil.Styles
---@field pos Vector2?
---@field size Vector2?
---@field sizing FOXStencil.Common.Sizing?
---@field scale Vector2?

---@alias FOXStencil.Common.Direction
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
---@field parn FOXStencil.Element.Any?
---@field chld FOXStencil.Element.Any[]?
local element = {}
---@protected
element.__index = element

---@alias FOXStencil.Element.Any FOXStencil.Element|FOXStencil.Element.Box|FOXStencil.Element.Outline|FOXStencil.Element.Slice|FOXStencil.Element.Label
---@alias FOXStencil.Styles.Any FOXStencil.Styles|FOXStencil.Styles.Box|FOXStencil.Styles.Outline|FOXStencil.Styles.Slice|FOXStencil.Styles.Label

---@class FOXStencil.Element.Container: FOXStencil.Element.Box
---@class FOXStencil.Styles.Container: FOXStencil.Styles.Box

---Creates a new container
---@param styles FOXStencil.Styles.Container?
---@return FOXStencil.Element.Container
function api.new(styles)
	styles = styles or {}

	styles.pos = styles.pos or vectors.vec2()
	styles.sizing = styles.sizing or {
		{ mode = "FIT", min = 0, max = math.huge },
		{ mode = "FIT", min = 0, max = math.huge },
	}
	styles.size = styles.size or vec(styles.sizing[1].min, styles.sizing[2].min)
	styles.scale = styles.scale or vec(1, 1)

	styles.pad = styles.pad or vectors.vec4()
	styles.gap = styles.gap or 0
	styles.dir = styles.dir or "hor"
	styles.align = styles.align or vectors.vec2()
	styles.justify = styles.justify or 0

	styles.color = styles.color or vectors.vec4()

	local elem = { type = "box", styl = styles, chld = {} }
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Container]]
end

---@class FOXStencil.Element.Box: FOXStencil.Element
---@field styl FOXStencil.Styles.Box
---@class FOXStencil.Styles.Box: FOXStencil.Styles
---@field pad Vector4? Margin around children
---@field gap number? Margin between children
---@field dir FOXStencil.Common.Direction?
---@field align Vector2?
---@field justify number?
---@field color Vector3|Vector4?

---Creates a new box
---@param styles FOXStencil.Styles.Box
---@return FOXStencil.Element.Box
function element:box(styles)
	styles.pos = styles.pos or vectors.vec2()
	styles.sizing = styles.sizing or {
		{ mode = "FIT", min = 0, max = math.huge },
		{ mode = "FIT", min = 0, max = math.huge },
	}
	styles.size = styles.size or vec(styles.sizing[1].min, styles.sizing[2].min)
	styles.scale = styles.scale or vec(1, 1)

	styles.pad = styles.pad or vectors.vec4()
	styles.gap = styles.gap or 0
	styles.dir = styles.dir or "hor"
	styles.align = styles.align or vectors.vec2()
	styles.justify = styles.justify or 0

	styles.color = styles.color or vectors.vec4()

	local elem = { type = "box", styl = styles, parn = self, chld = {} }
	table.insert(self.chld, elem)
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Box]]
end

---@class FOXStencil.Element.Outline: FOXStencil.Element
---@field styl FOXStencil.Styles.Outline
---@class FOXStencil.Styles.Outline: FOXStencil.Styles
---@field pad Vector4? Margin around children
---@field gap number? Margin between children
---@field dir FOXStencil.Common.Direction?
---@field align Vector2?
---@field justify number?
---@field color Vector3|Vector4?
---@field weight number?

---Creates a new outline
---@param styles FOXStencil.Styles.Outline
---@return FOXStencil.Element.Outline
function element:outline(styles)
	styles.pos = styles.pos or vectors.vec2()
	styles.sizing = styles.sizing or {
		{ mode = "FIT", min = 0, max = math.huge },
		{ mode = "FIT", min = 0, max = math.huge },
	}
	styles.size = styles.size or vec(styles.sizing[1].min, styles.sizing[2].min)
	styles.scale = styles.scale or vec(1, 1)

	styles.pad = styles.pad or vectors.vec4()
	styles.gap = styles.gap or 0
	styles.dir = styles.dir or "hor"
	styles.align = styles.align or vectors.vec2()
	styles.justify = styles.justify or 0

	styles.color = styles.color or vectors.vec4()
	styles.weight = styles.weight or 1

	local elem = { type = "outline", styl = styles, parn = self, chld = {} }
	table.insert(self.chld, elem)
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Outline]]
end

---@class FOXStencil.Common.Texture
---@field atlas Texture
---@field pos Vector2?
---@field size Vector2?
---@field slice Vector4?

---@class FOXStencil.Element.Slice: FOXStencil.Element
---@field styl FOXStencil.Styles.Slice
---@class FOXStencil.Styles.Slice: FOXStencil.Styles
---@field pad Vector4? Margin around children
---@field gap number? Margin between children
---@field dir FOXStencil.Common.Direction?
---@field align Vector2?
---@field justify number?
---@field texture FOXStencil.Common.Texture

---Creates a new 9 slice
---@param styles FOXStencil.Styles.Slice
---@return FOXStencil.Element.Slice
function element:slice(styles)
	styles.pos = styles.pos or vectors.vec2()
	styles.sizing = styles.sizing or {
		{ mode = "FIT", min = 0, max = math.huge },
		{ mode = "FIT", min = 0, max = math.huge },
	}
	styles.size = styles.size or vec(styles.sizing[1].min, styles.sizing[2].min)
	styles.scale = styles.scale or vec(1, 1)

	styles.pad = styles.pad or vectors.vec4()
	styles.gap = styles.gap or 0
	styles.dir = styles.dir or "hor"
	styles.align = styles.align or vectors.vec2()
	styles.justify = styles.justify or 0

	if not (styles.texture and styles.texture.atlas) then
		error("Slice element texture has missing required fields", 2)
	end

	styles.texture.pos = styles.texture.pos or vectors.vec2()
	styles.texture.size = styles.texture.size or styles.texture.atlas:getDimensions()
	styles.texture.slice = styles.texture.slice or vectors.vec4()

	local elem = { type = "slice", styl = styles, parn = self, chld = {} }
	table.insert(self.chld, elem)
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Slice]]
end

---@class FOXStencil.Element.Label: FOXStencil.Element
---@field styl FOXStencil.Styles.Label
---@class FOXStencil.Styles.Label: FOXStencil.Styles
---@field text string?
---@field outline Vector3?

---Creates a new text label
---@param styles FOXStencil.Styles.Label
---@return FOXStencil.Element.Label
function element:label(styles)
	styles.pos = styles.pos or vectors.vec2()
	styles.sizing = styles.sizing or {
		{ mode = "GROW", min = 0, max = math.huge },
		{ mode = "FIT", min = 0, max = math.huge },
	}
	styles.size = styles.size or vectors.vec2()
	styles.scale = styles.scale or vec(1, 1)

	styles.text = styles.text or ""

	local elem = { type = "label", styl = styles, parn = self }
	table.insert(self.chld, elem)
	return setmetatable(elem, element) --[[@as FOXStencil.Element.Label]]
end

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

return api
