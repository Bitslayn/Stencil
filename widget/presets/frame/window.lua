---@param class FOXStencil.Widgets.Window
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Window: FOXStencil.Widgets.Generic
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param name string
	---@param props FOXStencil.Props?
	---@return FOXStencil.Widgets.Window
	function elem:newWindow(name, props)
		local window = self:newElement(name, {
			tex_color = vec(0, 0, 0, 0),
			absolute_pos = true,
			vertical = true,
		})

		local visible = true
		local drag = false
		local anchor = vec(0, 0)
		local click_stamp = 0
		local last_pos = vec(0, 0)

		local function hover(rel_pos, true_pos, sound_pos, state, changed)
			if not drag then return end
			local pos = true_pos - anchor

			local parn = window.parn
			if parn then
				local padding = parn.props.padding
				pos = pos - padding.wz --[[@as Vector2]]
				pos.x = math.clamp(pos.x, 0, parn.state.size.x - window.state.size.x - padding.y - padding.w)
				pos.y = math.clamp(pos.y, 0, parn.state.size.y - window.state.size.y - padding.x - padding.z)
			end

			if last_pos == pos then return end
			last_pos = pos:copy()

			window:setProps({ pos = pos })
		end

		local tool, page

		tool = window:newElement("toolbar", {
			size_flex = { true, true },
			label = "Window",
			label_margin = vec(3, 2, 2, 3),

			tex = textures["assets.textures.ui"],
			tex_color = vec(0.3, 0.3, 0.3, 1),
			tex_uv_pos = vec(4, 0),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_extend = vec(0, 0, 1, 0),

			click = function(rel_pos, true_pos, sound_pos, state)
				drag = state
				anchor = true_pos - window.state.pos

				if not state then return end

				window:drop(math.huge)

				-- TODO After retained flex queue is fixed

				-- Check double click

				if client.getSystemTime() - click_stamp < 500 then
					visible = not visible
					page.state.visible = visible -- TODO Add visibility method
					tool:queue()
				else
					click_stamp = client.getSystemTime()
				end
			end,
			hover = hover,
		})

		page = window:newElement("page", {
			padding = vec(3, 3, 3, 3),

			size_flex = { true, true },

			tex = textures["assets.textures.ui"],
			tex_color = vec(0.3, 0.3, 0.3, 1),
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
		}):setProps(props or {}) --[[@as FOXStencil.Widgets.Window]]

		window:setProps({
			click = function(rel_pos, true_pos, sound_pos, state)
				drag = state
				anchor = true_pos - window.state.pos

				if not state then return end

				window:drop(math.huge)
			end,
			hover = hover,
		})

		return setmetatable(page, class)
	end
end
