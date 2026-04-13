---@type FOXStencil.Widgets.Generic
local super = require("./generic")

---@class FOXStencil.Widgets.Button.Props: FOXStencil.Widgets.Generic.Props
---@field hover fun(self: FOXStencil.Widgets.Button, pos: Vector2, state: boolean, changed: boolean)?
---@field click fun(self: FOXStencil.Widgets.Button, pos: Vector2, state: boolean)?
---@class FOXStencil.Widgets.Button: FOXStencil.Widgets.Generic
---@field setProps fun(self: self, props: FOXStencil.Widgets.Button.Props): self
---@field onClick fun(self: FOXStencil.Widgets.Button, pos: Vector2, state: boolean)?
---@field onHover fun(self: FOXStencil.Widgets.Button, pos: Vector2, state: boolean)?
local class = {}
---@package
function class:__index(k)
	return class[k] or super[k]
end

---@param func fun(self: FOXStencil.Widgets.Button, pos: Vector2, state: boolean)?
---@return self
function class:setOnClick(func)
	self.onClick = func
	return self
end

---@param func fun(self: FOXStencil.Widgets.Button, pos: Vector2, state: boolean)?
---@return self
function class:setOnHover(func)
	self.onHover = func
	return self
end

---@param elem FOXStencil.Element
return function(elem)
	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Widgets.Button.Props?
	---@return FOXStencil.Widgets.Button
	function elem:newButton(props)
		local btn = self:newElement() --[[@as FOXStencil.Widgets.Button]]
		local props_normal = {
			tex = textures["assets.textures.ui"],
			tex_color = vectors.hsvToRGB(math.random(), 1, 1),
			tex_pos = vec(0, 0),
			tex_size = vec(5, 7),
			tex_slice = vec(2, 2, 4, 2),
			tex_extend = vec(2, 0, 0, 0),
		}
		local props_pressed = {
			tex = textures["assets.textures.ui"],
			tex_color = vectors.hsvToRGB(math.random(), 1, 1),
			tex_pos = vec(4, 0),
			tex_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_extend = vec(0, 0, 0, 0),
		}
		local props_hovered = { border = vec(1, 1, 1, 1) }
		local props_hovered_away = { border = vec(0, 0, 0, 0) }
		local props_priority = props or {}

		btn.props_normal = props_normal
		btn.props_pressed = props_pressed
		btn.props_hovered = props_hovered
		btn.props_hovered_away = props_hovered_away
		btn.props_priority = props_priority

		btn:setProps({
			hover = function(_, pos, state, changed)
				if not changed then return end

				if btn.onHover then
					btn.onHover(btn, pos, state)
				end

				btn:setProps(state and props_hovered or props_hovered_away):setProps(props_priority):draw(true)
			end,
			click = function(_, pos, state)
				sounds:playSound(
					"minecraft:block.lava.pop",
					btn.part:partToWorldMatrix():apply(-pos.xy_),
					1,
					state and 8 or 9
				)

				if btn.onClick then
					btn.onClick(btn, pos, state)
				end

				btn:setProps(state and props_pressed or props_normal):setProps(props_priority):draw(true)
			end,
		}):setProps(props_normal):setProps(props_priority)

		return setmetatable(btn, class)
	end
end
