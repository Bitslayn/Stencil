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
	function elem:newButton(props)
		local button = self:newElement({
			size = vec(10, 10),

			click = function(window, rel_pos, true_pos, state)
				sounds:playSound(
					"minecraft:block.lava.pop",
					window.part:partToWorldMatrix():apply(-rel_pos.xy_),
					1,
					state and 8 or 9
				)
			end,
			hover = function(window, rel_pos, true_pos, state, changed)

			end,
		}):setProps(props or {}) --[[@as FOXStencil.Widget.Window]]

		button:newSlice():setStyles({
			texture = textures["assets.textures.ui"],
			uv = vec(0, 0),
			region = vec(5, 7),
			slice = vec(2, 2, 4, 2),
			extend = vec(2, 0, 0, 0),
		}):setStyles({
			uv = vec(4, 0),
			region = vec(5, 5),
			slice = vec(2, 2, 2, 2),
			extend = vec(0, 0, 0, 0),
		}, "click")

		return setmetatable(button, class) --[[@as FOXStencil.Widget.Window]]
	end

	---@return self
	function class:draw()
		local size = self.state.size

		self.layers[1] --[[@as FOXStencil.Layer.Slice]]:setStyles({
			size = size,
		})

		return elem.draw(self) --[[@as self]]
	end
end
