---@type FOXStencil.Widgets.Generic
local super = require(string.match(..., "^.+widgets") .. "/generic")

---@class FOXStencil.Widgets.Window.Props: FOXStencil.Widgets.Generic.Props
---@field hover fun(self: FOXStencil.Widgets.Window, pos: Vector2, state: boolean, changed: boolean)?
---@field click fun(self: FOXStencil.Widgets.Window, pos: Vector2, state: boolean)?
---@class FOXStencil.Widgets.Window: FOXStencil.Widgets.Generic
---@field setProps fun(self: self, props: FOXStencil.Widgets.Window.Props, group: FOXStencil.Element.Props.Group?): self
---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Window.Props
local class = {}
---@package
function class:__index(k)
	return class[k] or super[k]
end

---@param elem FOXStencil.Element
return function(elem)
	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Widgets.Window.Props?
	---@return FOXStencil.Widgets.Window
	function elem:newWindow(props)
		local window = self:newElement({
			pos = vec(5, 5),
			vertical = true,
		})

		local hidden = false
		local drag = false
		local anchor = vec(0, 0)

		local page

		local tool
		tool = window:newElement({
			size = vec(0, 15),
			size_min = vec(0, 15),
			size_max = vec(math.huge, 15),

			size_flex = { true, false },
			label = "Untitled",

			tex = textures["assets.textures.ui"],
			tex_color = vec(0.3, 0.3, 0.3, 1),
			tex_pos = vec(4, 0),
			tex_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_extend = vec(0, 0, 1, 0),

			click = function(_, pos, state)
				-- if not state then return end
				-- hidden = not hidden
				-- if hidden then
				-- 	page:remove()
				-- else
				-- 	page:moveTo(window)
				-- end

				drag = state
				anchor = client.getMousePos() / client.getGuiScale() - window.props.normal.pos
			end,
			hover = function(_, _, state, changed)
				if not drag then return end

				local pos = client.getMousePos() / client.getGuiScale() - anchor
				local max = client.getScaledWindowSize() - tool.state.size
				pos.y = math.clamp(pos.y, 0, max.y)
				pos.x = math.clamp(pos.x, 0, max.x)

				window:setProps({ pos = pos }):queue()
			end,
		})

		page = window:newElement({
			padding = vec(3, 3, 3, 3),

			tex = textures["assets.textures.ui"],
			tex_color = vec(0.3, 0.3, 0.3, 1),
			tex_pos = vec(4, 4),
			tex_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
		}):setProps(props or {}) --[[@as FOXStencil.Widgets.Window]]

		return setmetatable(page, class)
	end
end
