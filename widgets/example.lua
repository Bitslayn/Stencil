---@type FOXStencil.Widgets.Generic
local super = require(string.match(..., "^.+widgets") .. "/generic")

---@class FOXStencil.Widgets.EXAMPLE.Props: FOXStencil.Widgets.Generic.Props
---@field hover fun(self: FOXStencil.Widgets.EXAMPLE, pos: Vector2, state: boolean, changed: boolean)?
---@field click fun(self: FOXStencil.Widgets.EXAMPLE, pos: Vector2, state: boolean)?
---@class FOXStencil.Widgets.EXAMPLE: FOXStencil.Widgets.Generic
---@field setProps fun(self: self, props: FOXStencil.Widgets.EXAMPLE.Props, group: FOXStencil.Element.Props.Group?): self
---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.EXAMPLE.Props
local class = {}
---@package
function class:__index(k)
	return class[k] or super[k]
end

-- Functions registered on this class

---@return self
function class:example(func)
	print("Meow")
	return self
end

---@param elem FOXStencil.Element
return function(elem)
	---@class FOXStencil.Element
	elem = elem

	-- Create function registered to element superclass
	-- Be sure to change this

	---@param props FOXStencil.Widgets.EXAMPLE.Props?
	---@return FOXStencil.Widgets.EXAMPLE
	function elem:newExample(props)
		local widg = self:newElement() --[[@as FOXStencil.Widgets.EXAMPLE]]

		-- Set main props here

		widg:setProps({
			label = "Text",
			tex_color = vec(0, 0, 0, 0),

			-- Functions need to be defined if this element should be interactable, even if they are empty

			hover = function(_, pos, state, changed) end,
			click = function(_, pos, state) end,
		}):setProps(props or {})

		-- Set interact props
		-- Refrain from setting position and size as the layout is not updated when these are applied

		widg:setProps({ label = "Hovered" }, "hover")
		widg:setProps({ label = "Clicked" }, "click")

		-- Optional: Use in case of conflict in above props

		widg:setProps({ label = "Hovered + Clicked" }, "hover_click")

		return setmetatable(widg, class)
	end
end
