---@type FOXStencil.Widget.Generic
local super = require(string.match(..., "^.+widgets") .. "/generic")

---@class FOXStencil.Widgets.Label.Props: FOXStencil.Widget.Generic.Props
---@field click fun(self: FOXStencil.Widgets.Label, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
---@field hover fun(self: FOXStencil.Widgets.Label, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
---@class FOXStencil.Widgets.Label: FOXStencil.Widget.Generic
---@field setProps fun(self: self, props: FOXStencil.Widgets.Label.Props, group: FOXStencil.Element.Props.Group?): self
---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Label.Props
local class = {}
---@package
function class:__index(k)
	return class[k] or super[k]
end

---@param elem FOXStencil.Element
return function(elem)
	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Widgets.Label.Props?
	---@return FOXStencil.Widgets.Label
	function elem:newLabel(props)
		local widg = self:newElement() --[[@as FOXStencil.Widgets.Label]]

		widg:setProps({
			label = "Text",
			size_flex = { false, false }, -- TODO or something
			tex_color = vec(0, 0, 0, 0),
		}):setProps(props or {})

		return setmetatable(widg, class)
	end
end
