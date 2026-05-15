---@param class FOXStencil.Widgets.Switch
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Switch.Props: FOXStencil.Widgets.Generic.Props
	---@field click fun(self: FOXStencil.Widgets.Switch, rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean)?
	---@field hover fun(self: FOXStencil.Widgets.Switch, rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean, changed: boolean)?
	---@class FOXStencil.Widgets.Switch: FOXStencil.Widgets.Generic
	---@field setProps fun(self: self, props: FOXStencil.Widgets.Switch.Props, group: FOXStencil.Element.Props.Group?): self
	---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Switch.Props
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
	---@param props FOXStencil.Widgets.Switch.Props?
	---@return FOXStencil.Widgets.Switch
	function elem:newSwitch(name, props)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.Switch]]

		widg.toggled = false
		widg.uuid = client.intUUIDToString(client.generateUUID())
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

			click = function(_, rel_pos, _, sound_pos, state)
				if not state then return end

				sounds:playSound(
					"minecraft:block.lava.pop",
					sound_pos,
					1,
					widg.toggled and 8 or 9 -- Dev note: the toggled state is inverse to what's being applied
				)

				widg:setToggled(not widg.toggled)
			end,
		}):setProps(props or {})

		widg.switch:setProps({ tex_color = vectors.hexToRGB("red") })
		widg:setProps({ tex_color = vectors.hexToRGB("red") * 0.5 })

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

		-- Call function

		if self.toggle then
			self.toggle(self, self.toggled)
		end

		-- Animate switch

		local timer = state and 0 or 1
		local velocity = state and 0.8 or -0.8

		events.world_render:remove(self.uuid)
		events.world_render:register(function(delta)
			local l = math.lerp(timer, timer + velocity, delta)
			if l < 0 or 1 < l then
				l = math.clamp(l, 0, 1)
				self.switch:setProps({ tex_color = state and vectors.hexToRGB("green") or vectors.hexToRGB("red") })
				self:setProps({ tex_color = state and vectors.hexToRGB("green") * 0.5 or vectors.hexToRGB("red") * 0.5 })
				events.world_render:remove(self.uuid)
			end
			self:setProps({ align = vec(l, 0) })
			self.switch:queue()
		end, self.uuid)

		events.world_tick:remove(self.uuid)
		events.world_tick:register(function()
			timer = timer + velocity
			if timer < 0 or 1 < timer then
				timer = math.clamp(timer, 0, 1)
				events.world_tick:remove(self.uuid)
			end
		end, self.uuid)

		return self
	end
end
