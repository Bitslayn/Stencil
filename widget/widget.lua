---@type FOXStencil.Element
local super = require("../element/element").class

---@class FOXStencil.Widget.Props: FOXStencil.Props
---@field click fun(self: FOXStencil.Widget.Generic, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
---@field hover fun(self: FOXStencil.Widget.Generic, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
---@class FOXStencil.Widget.Generic: FOXStencil.Element
---@field setProps fun(self: self, props: FOXStencil.Widget.Props): self
local class = {}

local presets = listFiles(... .. "/presets", true)
for i = 1, #presets do
	local self = {}
	function self.__index(_, k)
		return self[k] or class[k] or super[k]
	end

	pcall(require(presets[i]), self, class, super)
end

---@generic self: FOXStencil.Widget.Generic
---@param self self
---@param x number
---@param y number?
---@return self
function class:setPos(x, y)
	y = y or x
	self.props.normal.pos = vec(x, y)
	return self
end

---@generic self: FOXStencil.Widget.Generic
---@param self self
---@param x number
---@param y number?
---@return self
function class:setSize(x, y)
	y = y or x
	self.props.normal.size = vec(x, y)
	return self
end

---@generic self: FOXStencil.Widget.Generic
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
	self.props.normal.padding = vec(x, y, z, w)
	return self
end

---@generic self: FOXStencil.Widget.Generic
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
	self.props.normal.margin = vec(x, y, z, w)
	return self
end

---@generic self: FOXStencil.Widget.Generic
---@param self self
---@param x number
---@return self
function class:setGap(x)
	self.props.normal.gap = x
	return self
end

---@generic self: FOXStencil.Widget.Generic
---@param self self
---@param x number
---@param y number?
---@return self
function class:setAlign(x, y)
	y = y or x
	self.props.normal.align = vec(x, y)
	return self
end

---@generic self: FOXStencil.Widget.Generic
---@param self self
---@param x number
---@return self
function class:setJustify(x)
	self.props.normal.justify = x
	return self
end

return setmetatable({}, class)
