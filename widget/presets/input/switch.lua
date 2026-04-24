---@param class FOXStencil.Widgets.Switch
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Switch.Props: FOXStencil.Widgets.Generic.Props
	---@field click fun(self: FOXStencil.Widgets.Switch, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
	---@field hover fun(self: FOXStencil.Widgets.Switch, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
	---@class FOXStencil.Widgets.Switch: FOXStencil.Widgets.Generic
	---@field setProps fun(self: self, props: FOXStencil.Widgets.Switch.Props, group: FOXStencil.Element.Props.Group?): self
	---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Switch.Props
	class = class

	---@class FOXStencil.Element
	elem = elem

	-- Create function registered to element superclass
	-- Be sure to change this

	---@param props FOXStencil.Widgets.Switch.Props?
	---@return FOXStencil.Widgets.Switch
	function elem:newSwitch(props)
		local widg = self:newElement() --[[@as FOXStencil.Widgets.Switch]]

		local a = false
		local s = false

		local t = 0
		local d = -0.8

		local switch = widg:newElement({
			size = vec(10, 0),
			size_flex = { false, true },

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(0, 0),
			tex_uv_size = vec(5, 7),
			tex_slice = vec(2, 2, 4, 2),
			tex_extend = vec(2, 0, 0, 0),

			border_extend = vec(0, 0, -2, 0),

			hover = function(_, pos, state, changed) end,
		})
		switch:setProps({ border = vec(1, 1, 1, 1) }, "hover")

		---@param rel_pos Vector2
		---@param state boolean
		local function toggle(_, rel_pos, _, state)
			if not state then return end
			if a then return end
			a = true
			s = not s
			d = -d

			local function render(delta)
				local l = math.lerp(t, t + d, delta)
				if l < 0 or 1 < l then
					a = false
					l = math.clamp(l, 0, 1)
					switch.props.normal.tex_color = s and vectors.hexToRGB("green") or vectors.hexToRGB("red")
					widg.props.normal.tex_color = s and vectors.hexToRGB("green") * 0.5 or vectors.hexToRGB("red") * 0.5
					events.world_render:remove(render)
				end
				widg.props.normal.align = vec(l, 0)
				switch:queue()
			end
			events.world_render:register(render)

			local function tick()
				t = t + d
				if t < 0 or 1 < t then
					t = math.clamp(t, 0, 1)
					events.world_tick:remove(tick)
				end
			end
			events.world_tick:register(tick)

			sounds:playSound(
				"minecraft:block.lava.pop",
				widg.part:partToWorldMatrix():apply(-rel_pos.xy_),
				1,
				s and 9 or 8
			)
		end
		switch.props.normal.click = toggle

		widg:setProps({
			size = vec(20, 10),

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_color = vec(0.5, 0.5, 0.5, 1),

			click = toggle,
		}):setProps(props or {})

		switch.props.normal.tex_color = vectors.hexToRGB("red")
		widg.props.normal.tex_color = vectors.hexToRGB("red") * 0.5

		return setmetatable(widg, class)
	end
end
