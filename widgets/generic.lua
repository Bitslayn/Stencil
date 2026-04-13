---@type FOXStencil.Element
local super = require("../element/class").class

---@class FOXStencil.Widgets.Generic.Props: FOXStencil.Element.Props
---@field hover fun(self: FOXStencil.Widgets.Generic, pos: Vector2, state: integer)?
---@field click fun(self: FOXStencil.Widgets.Generic, pos: Vector2, state: boolean)?
---@class FOXStencil.Widgets.Generic: FOXStencil.Element
---@field setProps fun(self: self, props: FOXStencil.Widgets.Generic.Props): self
---@field queue fun(self: self): self
---@field draw fun(self: self, forced: boolean): self
local class = {}
---@package
function class:__index(k)
	return class[k] or super[k]
end

return setmetatable({}, class)
