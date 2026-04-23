---@param class FOXStencil.Widgets.Field
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Field.Props: FOXStencil.Widgets.Generic.Props
	---@field click fun(self: FOXStencil.Widgets.Field, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
	---@field hover fun(self: FOXStencil.Widgets.Field, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
	---@class FOXStencil.Widgets.Field: FOXStencil.Widgets.Generic
	---@field setProps fun(self: self, props: FOXStencil.Widgets.Field.Props, group: FOXStencil.Element.Props.Group?): self
	---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Field.Props
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Widgets.Field.Props?
	---@return FOXStencil.Widgets.Field
	function elem:newField(props)
		local widg = self:newElement() --[[@as FOXStencil.Widgets.Field]]

		-- Set main props here

		widg:setProps({
			size = vec(80, 0),

			label = "Text",
			label_margin = vec(3, 2, 2, 3),
			label_align = vec(0, 0.5),

			tex = textures["assets.textures.ui"],
			tex_pos = vec(2, 6),
			tex_size = vec(3, 3),
			tex_slice = vec(1, 1, 1, 1),
			tex_extend = vec(0, 0, 0, 0),
			tex_color = vec(0.1, 0.1, 0.1),

			-- Functions need to be defined if this element should be interactable, even if they are empty

			hover = function(_, rel_pos, true_pos, state, changed) end,
			click = function(_, rel_pos, true_pos, state) end,
		}):setProps(props or {})
		widg:setProps({ border = vec(1, 1, 1, 1) }, "hover")

		return setmetatable(widg, class)
	end
end
