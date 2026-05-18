---@param class FOXStencil.Widgets.Slider
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Slider: FOXStencil.Widgets.Generic
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param name string
	---@param props FOXStencil.Props?
	---@return FOXStencil.Widgets.Slider
	function elem:newSlider(name, props)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.Slider]]

		local switch = widg:newElement("switch", {
			size = vec(10, 0),
			size_flex = { false, true },

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(0, 0),
			tex_uv_size = vec(5, 7),
			tex_slice = vec(2, 2, 4, 2),
			tex_extend = vec(2, 0, 0, 0),

			border_extend = vec(0, 0, -2, 0),
		})
		switch:setProps({ border = vec(1, 1, 1, 1) }, "hover")

		local drag
		local anchor = vec(0, 0)

		widg:setProps({
			size = vec(0, 10),
			size_min = vec(50, 0),
			size_flex = { true, false },

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vec(0.5, 0.5, 0.5, 1),

			click = function(rel_pos, true_pos, sound_pos, state)
				drag = state
				anchor = true_pos
			end,
			hover = function(rel_pos, true_pos, sound_pos, state, changed)
				if not drag then return end
				local slide_pos = (true_pos - anchor + rel_pos - switch.state.size / 2) /
					(widg.state.size - switch.state.size)
				-- slide_pos.x = math.round(slide_pos.x * 9) / 9
				switch.state.pos.x = math.clamp(slide_pos.x, 0, 1) * (widg.state.size.x - switch.state.size.x)
				switch:draw(true)
			end,
		}):setProps(props or {})

		return setmetatable(widg, class)
	end
end
