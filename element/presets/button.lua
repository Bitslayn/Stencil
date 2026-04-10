---@class FOXStencil.Button
local class

---@param elem FOXStencil.Element
return function(elem)
	---@class FOXStencil.Element
	elem = elem

	---@param props FOXStencil.Element.Props
	function elem:newButton(props)
		return self:newElement({
			tex = textures["assets.textures.ui"],
			tex_color = vectors.hsvToRGB(math.random(), 1, 1),
			tex_pos = vec(0, 0),
			tex_size = vec(5, 7),
			tex_slice = vec(2, 2, 4, 2),
			tex_extend = vec(2, 0, 0, 0),

			hover = function(btn, pos, state)
				if state == 2 then return end
				btn:setProps({ border = vectors.vec4() + state }):draw(true)
			end,
			click = function(btn, pos, state)
				sounds:playSound(
					"minecraft:block.lava.pop",
					btn.part:partToWorldMatrix():apply(-pos.xy_),
					1,
					state and 8 or 9
				)

				btn:setProps({
					tex_pos = vec(state and 4 or 0, 0),
					tex_size = vec(5, state and 5 or 7),
					tex_slice = vec(2, 2, state and 2 or 4, 2),
					tex_extend = vec(state and 0 or 2, 0, 0, 0),
				})

				if state then
					btn:setProps({
						tex_color = vectors.hsvToRGB(math.random(), 1, 1),
					})
				end

				btn:draw(true)
			end,
		}):setProps(props)
	end
end
