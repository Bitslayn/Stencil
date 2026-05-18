---@param class FOXStencil.Widgets.Label
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Label: FOXStencil.Widgets.Generic
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param name string
	---@param props FOXStencil.Props?
	---@return FOXStencil.Widgets.Label
	function elem:newLabel(name, props)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.Label]]

		widg:setProps({
			label = "Text",
			tex_color = vec(0, 0, 0, 0),
		}):setProps(props or {})

		return setmetatable(widg, class)
	end

	---@param str string
	---@return FOXStencil.Widgets.Label
	function class:setText(str)
		return self:setProps({ label = str })
	end
end
