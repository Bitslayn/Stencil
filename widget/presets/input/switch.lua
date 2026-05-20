---@param class FOXStencil.Widgets.Switch
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Switch: FOXStencil.Widgets.Generic
	---@field toggle fun(self: FOXStencil.Widgets.Switch, state: boolean)?
	---@field toggled boolean
	---@field uuid string
	---@field switch FOXStencil.Element
	class = class

	---@class FOXStencil.Element
	elem = elem

	-- Create function registered to element superclass
	-- Be sure to change this

	---@param name string
	---@return FOXStencil.Widgets.Switch
	function elem:newSwitch(name)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.Switch]]

		widg.toggled = false
		widg.switch = widg:newElement("switch", {
			size = vec(10, 0),
			size_flex = { false, true },

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(0, 0),
			tex_uv_size = vec(5, 7),
			tex_slice = vec(2, 2, 4, 2),
			tex_extend = vec(2, 0, 0, 0),

			border_extend = vec(0, 0, -2, 0),
		}):setProps({ border = vec(1, 1, 1, 1) }, "hover")

		widg:setProps({
			size = vec(20, 10),

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vec(0.5, 0.5, 0.5, 1),

			click = function(rel_pos, _, sound_pos, state)
				if not state then return end

				sounds:playSound(
					"minecraft:block.lava.pop",
					sound_pos,
					1,
					widg.toggled and 8 or 9 -- Dev note: the toggled state is inverse to what's being applied
				)

				widg:setToggled(not widg.toggled)
			end,
		})

		widg.switch:setProps({ tex_color = vectors.hexToRGB("red") })
		widg:setProps({ tex_color = vectors.hexToRGB("red") * 0.5 })

		widg.switch.state.auto_queue = false

		return setmetatable(widg, class)
	end

	---@param func fun(self: FOXStencil.Widgets.Switch, state: boolean)
	---@return FOXStencil.Widgets.Switch
	function class:onToggled(func)
		self.toggle = func
		return self
	end

	---@param state boolean
	---@return FOXStencil.Widgets.Switch
	function class:setToggled(state)
		state = state == nil and false or state
		if self.toggled == state then return self end
		self.toggled = state

		if self.toggle then
			self.toggle(self, self.toggled)
		end

		local range = self.state.size.x - self.switch.state.size.x
		local color = vectors.hexToRGB(state and "green" or "red")

		self.switch:setProps({ tex_color = color })
		self:setProps({ tex_color = color * 0.5 })

		self.switch.state.pos.x = math.lerp(0, range, state and 1 or 0)
		self:draw()
		self.switch:draw()

		return self
	end
end
