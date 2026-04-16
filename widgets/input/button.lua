---@type FOXStencil.Widgets.Generic
local super = require(string.match(..., "^.+widgets") .. "/generic")

---@class FOXStencil.Widgets.Button.Props: FOXStencil.Widgets.Generic.Props
---@field click fun(self: FOXStencil.Widgets.Button, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
---@field hover fun(self: FOXStencil.Widgets.Button, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
---@class FOXStencil.Widgets.Button: FOXStencil.Widgets.Generic
---@field setProps fun(self: self, props: FOXStencil.Widgets.Button.Props, group: FOXStencil.Element.Props.Group?): self
---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Button.Props
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
		local widg = self:newElement() --[[@as FOXStencil.Widgets.Button]]

		widg:setProps({
			tex = textures["assets.textures.ui"],
			tex_pos = vec(0, 0),
			tex_size = vec(5, 7),
			tex_slice = vec(2, 2, 4, 2),
			tex_extend = vec(2, 0, 0, 0),

			border = vec(0, 0, 0, 0),
			border_extend = vec(0, 0, -2, 0),

			hover = function(_, pos, state, changed)
				if not changed then return end

				if widg.onHover then
					widg.onHover(widg, pos, state)
				end
			end,
			click = function(_, pos, state)
				sounds:playSound(
					"minecraft:block.lava.pop",
					widg.part:partToWorldMatrix():apply(-pos.xy_),
					1,
					state and 8 or 9
				)

				if widg.onClick then
					widg.onClick(widg, pos, state)
				end
			end,
		}):setProps(props or {})

		widg:setProps({ border = vec(1, 1, 1, 1) }, "hover")
		widg:setProps({
			tex_pos = vec(4, 0),
			tex_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_extend = vec(0, 0, 0, 0),
		}, "click")

		return setmetatable(widg, class)
	end
end
