---@param class FOXStencil.Widgets.Label
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Label.Props: FOXStencil.Widgets.Generic.Props
	---@field click fun(self: FOXStencil.Widgets.Label, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
	---@field hover fun(self: FOXStencil.Widgets.Label, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
	---@class FOXStencil.Widgets.Label: FOXStencil.Widgets.Generic
	---@field setProps fun(self: self, props: FOXStencil.Widgets.Label.Props, group: FOXStencil.Element.Props.Group?): self
	---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Label.Props
	class = class

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
