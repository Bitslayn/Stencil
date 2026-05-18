---@param class FOXStencil.Widgets.Field
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Field: FOXStencil.Widgets.Generic
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param name string
	---@param props FOXStencil.Props?
	---@return FOXStencil.Widgets.Field
	function elem:newField(name, props)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.Field]]

		-- Set main props here

		widg:setProps({
			size = vec(80, 0),

			label = "Text",
			label_margin = vec(3, 2, 2, 3),
			label_align = vec(0, 0.5),

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(2, 6),
			tex_uv_size = vec(3, 3),
			tex_slice = vec(1, 1, 1, 1),
			tex_extend = vec(0, 0, 0, 0),
			tex_color = vec(0.1, 0.1, 0.1),
		}):setProps(props or {})
		widg:setProps({ border = vec(1, 1, 1, 1) }, "hover")

		return setmetatable(widg, class)
	end
end
