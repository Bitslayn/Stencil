---@param class FOXStencil.Widgets.Button
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Button.Props: FOXStencil.Widgets.Generic.Props
	---@field click fun(self: FOXStencil.Widgets.Button, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
	---@field hover fun(self: FOXStencil.Widgets.Button, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
	---@class FOXStencil.Widgets.Button: FOXStencil.Widgets.Generic
	---@field setProps fun(self: self, props: FOXStencil.Widgets.Button.Props, group: FOXStencil.Element.Props.Group?): self
	---@field getProps fun(self: self, group: FOXStencil.Element.Props.Group?): FOXStencil.Widgets.Button.Props
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Widgets.Button.Props?
	---@return FOXStencil.Widgets.Button
	function elem:newButton(props)
		local widg = self:newElement() --[[@as FOXStencil.Widgets.Button]]

		widg:setProps({
			label = "Button",
			label_margin = vec(3, 2, 2, 3),

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(0, 0),
			tex_uv_size = vec(5, 7),
			tex_slice = vec(2, 2, 4, 2),
			tex_extend = vec(2, 0, 0, 0),

			border = vec(0, 0, 0, 0),
			border_extend = vec(0, 0, -2, 0),

			click = function(_, rel_pos, true_pos, state)
				sounds:playSound(
					"minecraft:block.lava.pop",
					widg.part:partToWorldMatrix():apply(-rel_pos.xy_),
					1,
					state and 8 or 9
				)
				-- sounds:playSound(
				-- 	"minecraft:block.lava.pop",
				-- 	player:getPos(),
				-- 	1,
				-- 	state and 8 or 9
				-- )
			end,
		}):setProps(props or {})

		widg:setProps({ border = vec(1, 1, 1, 1) }, "hover")
		widg:setProps({
			tex_uv_pos = vec(4, 0),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_extend = vec(0, 0, 0, 0),
		}, "click")

		return setmetatable(widg, class)
	end
end
