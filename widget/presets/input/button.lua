---@param class FOXStencil.Widgets.Button
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Button: FOXStencil.Widgets.Generic
	---@field press fun(self: FOXStencil.Widgets.Button)?
	---@field release fun(self: FOXStencil.Widgets.Button)?
	class = class

	---@class FOXStencil.Element
	elem = elem

	---@param name string
	---@param props FOXStencil.Props?
	---@return FOXStencil.Widgets.Button
	function elem:newButton(name, props)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.Button]]

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

			click = function(rel_pos, true_pos, sound_pos, state)
				sounds:playSound(
					"minecraft:block.lava.pop",
					sound_pos,
					1,
					state and 8 or 9
				)

				-- Call functions

				if state then
					if type(widg.press) == "function" then
						widg.press(widg)
					end
				else
					if type(widg.release) == "function" then
						widg.release(widg)
					end
				end
			end,
		}):setProps(props or {})

		-- widg:setProps({ border = vec(1, 1, 1, 1) }, "hover")
		-- widg:setProps({
		-- 	tex_uv_pos = vec(4, 0),
		-- 	tex_uv_size = vec(5, 5),
		-- 	tex_slice = vec(2, 2, 2, 2),
		-- 	tex_extend = vec(0, 0, 0, 0),
		-- }, "click")

		return setmetatable(widg, class)
	end

	---@param func fun(self: FOXStencil.Widgets.Button)
	---@return FOXStencil.Widgets.Button
	function class:onPress(func)
		self.press = func
		return self
	end

	---@param func fun(self: FOXStencil.Widgets.Button)
	---@return FOXStencil.Widgets.Button
	function class:onRelease(func)
		self.release = func
		return self
	end
end
