---@param class FOXStencil.Widgets.Progress
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Progress.Props: FOXStencil.Widgets.Generic.Props
	---@field click fun(self: FOXStencil.Widgets.Progress, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
	---@field hover fun(self: FOXStencil.Widgets.Progress, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
	---@class FOXStencil.Widgets.Progress: FOXStencil.Widgets.Generic
	---@field setProps fun(self: self, props: FOXStencil.Widgets.Progress.Props, group: FOXStencil.Element.Props.Group?): self
	---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Progress.Props
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Widgets.Progress.Props?
	---@return FOXStencil.Widgets.Progress
	function elem:newProgress(props)
		local widg = self:newElement() --[[@as FOXStencil.Widgets.Progress]]

		local switch = widg:newElement({
			size = vec(10, 0),
			size_flex = { false, true },

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_reg_size = vec(50, 10),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vectors.hexToRGB("blue"),

			hover = function(_, rel_pos, true_pos, state, changed) end,
		})

		local drag
		local anchor = vec(0, 0)

		widg:setProps({
			size = vec(50, 10),

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vec(0.5, 0.5, 0.5, 1),

			click = function(_, rel_pos, true_pos, state)
				drag = state
				anchor = true_pos
			end,
			hover = function(_, rel_pos, true_pos, state, changed)
				if not drag then return end
				local slide_pos = (true_pos - anchor + rel_pos) / widg.state.size
				-- slide_pos.x = math.round(slide_pos.x * 9) / 9
				switch.state.size.x = math.clamp(slide_pos.x, 0, 1) * widg.state.size.x
				switch:draw(true)
			end,
		}):setProps(props or {})

		return setmetatable(widg, class)
	end
end
