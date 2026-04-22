---@param class FOXStencil.Widgets.Checkbox
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Checkbox.Props: FOXStencil.Widgets.Generic.Props
	---@field click fun(self: FOXStencil.Widgets.Checkbox, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
	---@field hover fun(self: FOXStencil.Widgets.Checkbox, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
	---@class FOXStencil.Widgets.Checkbox: FOXStencil.Widgets.Generic
	---@field setProps fun(self: self, props: FOXStencil.Widgets.Checkbox.Props, group: FOXStencil.Element.Props.Group?): self
	---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Checkbox.Props
	class = class

	---@class FOXStencil.Element
	elem = elem

	-- Create function registered to element superclass
	-- Be sure to change this

	---@param props FOXStencil.Widgets.Checkbox.Props?
	---@return FOXStencil.Widgets.Checkbox
	function elem:newCheckbox(props)
		local widg = self:newElement() --[[@as FOXStencil.Widgets.Checkbox]]

		local toggled = false

		widg:setProps({
			size = vec(10, 10),

			tex = textures["assets.textures.ui"],
			tex_pos = vec(4, 4),
			tex_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_extend = vec(0, 0, 0, 0),

			tex_color = vec(0.5, 0.5, 0.5),

			-- Functions need to be defined if this element should be interactable, even if they are empty

			hover = function(_, rel_pos, true_pos, state, changed) end,
			click = function(_, rel_pos, true_pos, state)
				if not state then return end
				toggled = not toggled

				if toggled then
					widg:setProps({
						tex_color = vectors.hexToRGB("blue"),
						tex_pos = vec(4, 0),
					})
				else
					widg:setProps({
						tex_color = vec(0.5, 0.5, 0.5),
						tex_pos = vec(4, 4),
					})
				end
			end,
		}):setProps(props or {})

		widg:setProps({ border = vec(1, 1, 1, 1) }, "hover")

		return setmetatable(widg, class)
	end
end
