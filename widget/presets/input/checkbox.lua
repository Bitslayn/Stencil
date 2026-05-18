---@param class FOXStencil.Widgets.Checkbox
---@param super FOXStencil.Widgets.Generic
---@param elem FOXStencil.Element
return function(class, super, elem)
	---@class FOXStencil.Widgets.Checkbox: FOXStencil.Widgets.Generic
	---@field toggle fun(self: FOXStencil.Widgets.Checkbox, state: boolean)?
	---@field toggled boolean
	---@field id string
	class = class

	---@class FOXStencil.Element
	elem = elem

	---TODO Remove id and groups, moving this functionality to siblings
	---@type table<string, FOXStencil.Widgets.Checkbox[]>
	local groups = {}

	---@param name string
	---@param props FOXStencil.Props?
	---@param id string?
	---@return FOXStencil.Widgets.Checkbox
	function elem:newCheckbox(name, props, id)
		local widg = self:newElement(name) --[[@as FOXStencil.Widgets.Checkbox]]

		widg.toggled = false

		if type(id) == "string" then
			if not groups[id] then
				groups[id] = {}
			end
			table.insert(groups[id], widg)
			widg.id = id
		end

		widg:setProps({
			size = vec(10, 10),

			tex = textures["assets.textures.ui"],
			tex_uv_pos = vec(4, 4),
			tex_uv_size = vec(5, 5),
			tex_slice = vec(2, 2, 2, 2),
			tex_extend = vec(0, 0, 0, 0),

			tex_color = vec(0.5, 0.5, 0.5),

			click = function(rel_pos, true_pos, sound_pos, state)
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

		widg:setProps({ border = vec(1, 1, 1, 1) }, "hover")

		return setmetatable(widg, class)
	end

	---@param func fun(self: FOXStencil.Widgets.Checkbox, state: boolean)
	---@return FOXStencil.Widgets.Checkbox
	function class:onToggled(func)
		self.toggle = func
		return self
	end

	---@param state boolean
	---@return FOXStencil.Widgets.Checkbox
	function class:setToggled(state)
		state = state == nil and false or state
		if self.toggled == state then return self end
		self.toggled = state

		local group = groups[self.id]
		if state and group then
			for i = 1, #group do
				if group[i] ~= self then
					group[i]:setToggled(false)
				end
			end
		end

		-- Call function

		if self.toggle then
			self.toggle(self, self.toggled)
		end

		-- Update style

		if self.toggled then
			self:setProps({
				tex_color = vectors.hexToRGB("blue"),
				tex_uv_pos = vec(4, 0),
			})
		else
			self:setProps({
				tex_color = vec(0.5, 0.5, 0.5),
				tex_uv_pos = vec(4, 4),
			})
		end

		self:draw(true)

		return self
	end
end
