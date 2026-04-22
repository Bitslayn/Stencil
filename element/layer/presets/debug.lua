---@param super FOXStencil.Layer
---@param elem FOXStencil.Element
return function(super, elem)
	---@class FOXStencil.Layer.Debug: FOXStencil.Layer
	---@field tasks SpriteTask[]
	local class = {}
	---@package
	function class:__index(k)
		return class[k] or super[k]
	end

	---@class FOXStencil.Element
	elem = elem

	---@return FOXStencil.Layer.Debug
	function elem:newDebug()
		local layer = super.new(self)

		---@class FOXStencil.Styles.Debug
		layer.styles[0] = {
			pos = vec(0, 0),
			size = vec(0, 0),

			color = vec(1, 1, 1, 1),
		}

		for i = 1, 2 do
			layer.tasks[i] = layer.elem.part:newSprite("debug-" .. layer.id .. "-" .. i)
				:texture(textures["FOXStencil_blank"], 1, 1)
				:renderType("LINES")
		end
		layer.tasks[2]:rot(0, 180, -90)

		return setmetatable(layer, class) --[[@as FOXStencil.Layer.Debug]]
	end

	function class:draw()
		local styles = self.styles --[[@as FOXStencil.Styles.Debug]]

		self.tasks[1]:pos(styles.pos.xy_):scale(styles.size.xy_ --[[@as Vector3]]):color(styles.color)
		self.tasks[2]:pos(styles.pos.xy_):scale(styles.size.yx_ --[[@as Vector3]]):color(styles.color)
	end
end
