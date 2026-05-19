---@param class FOXStencil.Widgets.Progress
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Progress: FOXStencil.Widgets.Generic
	---@field bar FOXStencil.Element
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param name string
	---@return FOXStencil.Widgets.Progress
	function elem:newProgress(name)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.Progress]]

		widg.bar = widg:newElement("bar", {
			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vectors.hexToRGB("blue"),
		})

		widg.bar.state.auto_queue = false

		widg:setProps({
			size = vec(0, 10),
			size_flex = { true, false },

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vec(0.5, 0.5, 0.5, 1),
		})

		return setmetatable(widg, class)
	end

	---@param n number
	---@return FOXStencil.Widgets.Progress
	function class:setProgress(n)
		self.bar:setProps({ tex_reg_size = self.state.size })
		self.bar.state.size = vec(
			math.clamp(n, 0, 1) * self.state.size.x,
			self.state.size.y
		)

		self.bar:draw()

		return self
	end
end
