---@param class FOXStencil.Widget.Window
---@param super FOXStencil.Widget.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widget.Window: FOXStencil.Widget.Generic
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Widget.Props?
	---@return FOXStencil.Widget.Window
	function elem:newWindow(props)
		local drag = false
		local anchor = vec(0, 0)

		local window = self:newElement({
			size = vec(0, 0),
			padding = vec(13, 3, 3, 3),

			click = function(window, rel_pos, true_pos, state)
				if state then
					window:drop(math.huge)
				end

				drag = state
				anchor = rel_pos
			end,
			hover = function(window, rel_pos, true_pos, state, changed)
				if not drag then return end
				window:setProps({ pos = true_pos - anchor }):queue()
			end,
		}):setProps(props or {}) --[[@as FOXStencil.Widget.Window]]

		window:newSlice():setStyles({
			size = vec(10, 10),

			texture = textures["assets.textures.ui"],
			color = vec(0.3, 0.3, 0.3, 1),
			uv = vec(4, 0),
			region = vec(5, 5),
			slice = vec(2, 2, 2, 2),
			extend = vec(0, 0, 1, 0),
		})

		window:newSlice():setStyles({
			pos = vec(0, 10),

			texture = textures["assets.textures.ui"],
			color = vec(0.3, 0.3, 0.3, 1),
			uv = vec(4, 4),
			region = vec(5, 5),
			slice = vec(2, 2, 2, 2),
		})

		return setmetatable(window, class) --[[@as FOXStencil.Widget.Window]]
	end

	---@return self
	function class:draw()
		local size = self.state.size
		local pad = self.state.padding

		self.layers[1] --[[@as FOXStencil.Layer.Slice]]:setStyles({
			size = vec(size.x, 10),
		})
		self.layers[2] --[[@as FOXStencil.Layer.Slice]]:setStyles({
			size = vec(size.x, size.y - 10),
		})

		return elem.draw(self) --[[@as self]]
	end
end
