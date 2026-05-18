---@param class FOXStencil.Widgets.EXAMPLE
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.EXAMPLE: FOXStencil.Widgets.Generic
	class = class

	---@class FOXStencil.Element
	elem = elem

	---Test funciton
	---@return self
	function class:meow(func)
		print("Meow")
		return self
	end

	-- Create function registered to element superclass
	-- Be sure to change this

	---@param name string
	---@return FOXStencil.Widgets.EXAMPLE
	function elem:newExample(name)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.EXAMPLE]]

		-- Set main props here

		widg:setProps({
			label = "Text",
			tex_color = vec(0, 0, 0, 0),
		})

		return setmetatable(widg, class)
	end
end
