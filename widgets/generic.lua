---@type FOXStencil.Element
local super = require("../element/class").class

---@class FOXStencil.Widgets.Generic.Props: FOXStencil.Element.Props
---@field hover fun(self: FOXStencil.Widgets.Generic, pos: Vector2, state: boolean, changed: boolean)?
---@field click fun(self: FOXStencil.Widgets.Generic, pos: Vector2, state: boolean)?
---@class FOXStencil.Widgets.Generic: FOXStencil.Element
---@field setProps fun(self: self, props: FOXStencil.Widgets.Generic.Props, group: FOXStencil.Element.Props.Group?): self
local class = {}
---@package
function class:__index(k)
	return class[k] or super[k]
end

---@generic self: FOXStencil.Widgets.Generic
---@param self self
---@param x number
---@param y number?
---@return self
function class:setPos(x, y)
	y = y or x
	self.props.normal.pos = vectors.vec2():set(x, y)
	return self
end

---@generic self: FOXStencil.Widgets.Generic
---@param self self
---@param x number
---@param y number?
---@return self
function class:setSize(x, y)
	y = y or x
	self.props.normal.size = vectors.vec2():set(x, y)
	return self
end

---@generic self: FOXStencil.Widgets.Generic
---@param self self
---@param x number
---@param y number?
---@param z number?
---@param w number?
---@return self
---@overload fun(self: self, top: number, right: number, bottom: number, left: number)
---@overload fun(self: self, top: number, horizontal: number, bottom: number)
---@overload fun(self: self, vertical: number, horizontal: number)
---@overload fun(self: self, all: number)
function class:setPadding(x, y, z, w)
	-- a          -> a, a, a, a
	-- a, b       -> a, b, a, b
	-- a, b, c    -> a, b, c, b
	-- a, b, c, d -> a, b, c, d

	y = y or x
	z = z or x
	w = w or y or x
	self.props.normal.padding = vectors.vec4():set(x, y, z, w)
	return self
end

---@generic self: FOXStencil.Widgets.Generic
---@param self self
---@param x number
---@param y number?
---@param z number?
---@param w number?
---@return self
---@overload fun(self: self, top: number, right: number, bottom: number, left: number)
---@overload fun(self: self, top: number, horizontal: number, bottom: number)
---@overload fun(self: self, vertical: number, horizontal: number)
---@overload fun(self: self, all: number)
function class:setMargin(x, y, z, w)
	-- a          -> a, a, a, a
	-- a, b       -> a, b, a, b
	-- a, b, c    -> a, b, c, b
	-- a, b, c, d -> a, b, c, d

	y = y or x
	z = z or x
	w = w or y or x
	self.props.normal.margin = vectors.vec4():set(x, y, z, w)
	return self
end

---@generic self: FOXStencil.Widgets.Generic
---@param self self
---@param x number
---@return self
function class:setGap(x)
	self.props.normal.gap = x
	return self
end

---@generic self: FOXStencil.Widgets.Generic
---@param self self
---@param x number
---@param y number?
---@return self
function class:setAlign(x, y)
	y = y or x
	self.props.normal.align = vectors.vec2():set(x, y)
	return self
end

---@generic self: FOXStencil.Widgets.Generic
---@param self self
---@param x number
---@return self
function class:setJustify(x)
	self.props.normal.justify = x
	return self
end

return setmetatable({}, class)
