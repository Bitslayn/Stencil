---@type FOXStencil.Widgets.Generic
local super = require(string.match(..., "^.+widgets") .. "/generic")

---@class FOXStencil.Widgets.Slider.Props: FOXStencil.Widgets.Generic.Props
---@field click fun(self: FOXStencil.Widgets.Slider, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
---@field hover fun(self: FOXStencil.Widgets.Slider, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
---@class FOXStencil.Widgets.Slider: FOXStencil.Widgets.Generic
---@field setProps fun(self: self, props: FOXStencil.Widgets.Slider.Props, group: FOXStencil.Element.Props.Group?): self
---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Slider.Props
local class = {}
---@package
function class:__index(k)
	return class[k] or super[k]
end

---@param elem FOXStencil.Element
return function(elem)
	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Widgets.Slider.Props?
	---@return FOXStencil.Widgets.Slider
	function elem:newSlider(props)
		local widg = self:newElement() --[[@as FOXStencil.Widgets.Slider]]

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
