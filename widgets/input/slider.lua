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

		local switch = widg:newElement({
			size = vec(10, 0),
			size_flex = { false, true },

			tex = textures["assets.textures.ui"],
			tex_pos = vec(0, 0),
			tex_size = vec(5, 7),
			tex_slice = vec(2, 2, 4, 2),
			tex_extend = vec(2, 0, 0, 0),

			border_extend = vec(0, 0, -2, 0),

			hover = function(_, pos, state, changed) end,
		})
		switch:setProps({ border = vec(1, 1, 1, 1) }, "hover")

		local drag
		local anchor = vec(0, 0)

		widg:setProps({
			size = vec(50, 10),

			tex = textures["assets.textures.ui"],
			tex_pos = vec(4, 4),
			tex_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vec(0.5, 0.5, 0.5, 1),

			click = function(_, rel_pos, true_pos, state)
				drag = state
				anchor = true_pos
			end,
			hover = function(_, rel_pos, true_pos, state, changed)
				if not drag then return end
				widg.props.normal.align = (true_pos - anchor + rel_pos) / widg.state.size
				switch:queue()
			end,
		}):setProps(props or {})

		return setmetatable(widg, class)
	end
end
