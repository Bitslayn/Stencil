---@param class FOXStencil.Widgets.Window
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Window.Props: FOXStencil.Widgets.Generic.Props
	---@field click fun(self: FOXStencil.Widgets.Window, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
	---@field hover fun(self: FOXStencil.Widgets.Window, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
	---@class FOXStencil.Widgets.Window: FOXStencil.Widgets.Generic
	---@field setProps fun(self: self, props: FOXStencil.Widgets.Window.Props, group: FOXStencil.Element.Props.Group?): self
	---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Window.Props
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Widgets.Window.Props?
	---@return FOXStencil.Widgets.Window
	function elem:newWindow(props)
		local window = self:newElement({
			tex_color = vec(0, 0, 0, 0),
			pos = vec(10, 10),
			vertical = true,
		})

		local visible = true
		local drag = false
		local anchor = vec(0, 0)
		local click_stamp = 0

		local page

		local tool
		tool = window:newElement({
			size_flex = { true, true },
			label = "Window",
			label_margin = vec(3, 2, 2, 3),

			tex = textures["assets.textures.ui"],
			tex_color = vec(0.3, 0.3, 0.3, 1),
			tex_pos = vec(4, 0),
			tex_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_extend = vec(0, 0, 1, 0),

			click = function(_, rel_pos, true_pos, state)
				if state then
					window:drop(math.huge)

					-- TODO After retained flex queue is fixed

					-- Check double click

					if client.getSystemTime() - click_stamp < 500 then
						visible = not visible
						page.state.visible = visible
						page:queue()
					else
						click_stamp = client.getSystemTime()
					end
				end

				drag = state
				anchor = rel_pos
			end,
			hover = function(_, rel_pos, true_pos, state, changed)
				if not drag then return end
				window:setProps({ pos = true_pos - anchor }):queue()
			end,
		})

		page = window:newElement({
			padding = vec(3, 3, 3, 3),

			size_flex = { true, true },

			tex = textures["assets.textures.ui"],
			tex_color = vec(0.3, 0.3, 0.3, 1),
			tex_pos = vec(4, 4),
			tex_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
		}):setProps(props or {}) --[[@as FOXStencil.Widgets.Window]]

		return setmetatable(page, class)
	end
end
