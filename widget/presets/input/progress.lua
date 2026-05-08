---@param class FOXStencil.Widgets.Progress
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Progress.Props: FOXStencil.Widgets.Generic.Props
	---@field click fun(self: FOXStencil.Widgets.Progress, rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean)?
	---@field hover fun(self: FOXStencil.Widgets.Progress, rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean, changed: boolean)?
	---@class FOXStencil.Widgets.Progress: FOXStencil.Widgets.Generic
	---@field setProps fun(self: self, props: FOXStencil.Widgets.Progress.Props, group: FOXStencil.Element.Props.Group?): self
	---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Progress.Props
	---@field bar FOXStencil.Element
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param name string
	---@param props FOXStencil.Widgets.Progress.Props?
	---@return FOXStencil.Widgets.Progress
	function elem:newProgress(name, props)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.Progress]]

		widg.bar = widg:newElement(name, {
			size_flex = { false, true },

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_reg_size = vec(50, 10),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vectors.hexToRGB("blue"),
		})

		widg:setProps({
			size = vec(0, 10),
			size_min = vec(50, 0),
			size_flex = { true, false },

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vec(0.5, 0.5, 0.5, 1),
		}):setProps(props or {})

		return setmetatable(widg, class)
	end

	---@param n number
	---@return FOXStencil.Widgets.Progress
	function class:setProgress(n)
		self.bar:setProps({ tex_reg_size = self.state.size })
		self.bar.state.size.x = math.clamp(n, 0, 1) * self.state.size.x
		self.bar:draw(true)
		return self
	end
end
