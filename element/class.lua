---@class FOXStencil.Element
local class = {}
---@package
class.__index = class

---@param part ModelPart
---@param root FOXStencil.Layout
---@param parn FOXStencil.Element?
---@return FOXStencil.Element
local function new(part, root, parn)
	---@class FOXStencil.Element
	local self = {
		part = part,

		---@class FOXStencil.Element.Props
		---@field hover fun(self: FOXStencil.Element, pos: Vector2, state: integer)?
		---@field click fun(self: FOXStencil.Element, pos: Vector2, state: boolean)?
		props = {
			pos = vec(0, 0),
			live_pos = vec(0, 0),
			layer = 0,

			scale = vec(1, 1),

			size = vec(0, 0),
			size_min = vec(0, 0),
			size_max = vec(0, 0),
			size_flex = { false, false },
			live_size = vec(0, 0),
			live_size_min = vec(0, 0),
			live_size_max = vec(0, 0),

			border = vec(0, 0, 0, 0),
			border_color = vec(1, 1, 1, 1),
			border_extend = vec(0, 0, 0, 0),

			padding = vec(0, 0, 0, 0),
			margin = vec(0, 0, 0, 0),

			tex = textures["FOXStencil_blank"] --[[@as Texture]],
			tex_pos = vec(0, 0),
			tex_size = vec(1, 1),
			tex_color = vec(1, 1, 1, 1),
			tex_extend = vec(0, 0, 0, 0),
			tex_slice = vec(0, 0, 0, 0),

			label = "",
			label_shadow = false,

			vertical = false,
			gap = 0,
			align = vec(0, 0),
			justify = 0,
		},

		root = root,
		parn = parn,
		chld = require("./map")() --[[@as FOXMap<integer, FOXStencil.Element>]],

		skip = false,
	}
	self.layers = {
		require("./layers/slice")(self),
		require("./layers/border")(self),
		require("./layers/label")(self),
	}
	return setmetatable(self, class)
end

---@param props FOXStencil.Element.Props?
---@return FOXStencil.Element
function class:newElement(props)
	local elem = new(self.part:newPart("elem"), self.root, self):setProps(props)
	self.chld:push(elem)
	return elem
end

---@param props FOXStencil.Element.Props?
---@return self
function class:setProps(props)
	for k, v in pairs(props or {}) do
		local t = type(v)
		if t == "table" then
			v = { table.unpack(v) }
		elseif t:find("^Vector") then
			v = v:copy()
		end
		self.props[k] = v
	end
	return self
end

---@return self
function class:queue()
	-- Queue parent tree

	local tree = self
	repeat
		tree.skip = false
		tree = tree.parn
	until not tree

	return self
end

---@return self
function class:draw()
	self.part:pos(-self.props.live_pos:augmented(self.props.layer))
	self.layers[1]:draw()
	self.layers[2]:draw()
	self.layers[3]:draw()
	return self
end

return new
