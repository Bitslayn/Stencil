---@class FOXStencil.Element
local class = {}
---@package
class.__index = class

---@alias FOXStencil.Element.Props.Group "normal"|"hover"|"click"|"hover_click"

---@param part ModelPart
---@param root FOXStencil.Screen
---@param parn FOXStencil.Element?
---@param sibl FOXMap<integer, FOXStencil.Element>
---@return FOXStencil.Element
local function new(part, root, parn, sibl)
	---@class FOXStencil.Element
	local self = setmetatable({
		part = part,

		group = 0,
		props = {
			---@class FOXStencil.Element.Props
			---@field click fun(self: FOXStencil.Element, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
			---@field hover fun(self: FOXStencil.Element, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
			normal = {
				---This element's preferred offset position
				pos = vec(0, 0),

				---This element's preferred size
				size = vec(0, 0),
				---This element's minimum size
				size_min = vec(0, 0),
				---This element's maximum size
				size_max = vec(0, 0),
				---States define whether this element is allowed to dynamically scale within min and max bounds
				---@type [boolean, boolean]
				size_flex = { false, false },

				---Child padding, or space around children
				padding = vec(0, 0, 0, 0),
				---Element margin, or space around element
				margin = vec(0, 0, 0, 0),
				---Child gap, or space between children
				gap = 0,
				---Child layout direction, false is horizontal and true is vertical
				---@type boolean
				vertical = false,
				---Child gravity or alignment. (0, 0) is top-left and (1, 1) is bottom-right
				align = vec(0, 0),
				---Percentage (0 to 1) of available space distributed between children rather than around children
				justify = 0,

				---Background texture
				---@type Texture
				tex = textures["FOXStencil_blank"],
				---UV position on the texture
				tex_uv_pos = vec(0, 0),
				---UV region on the texture
				tex_uv_size = vec(1, 1),
				---Background tint
				---@type Vector3|Vector4
				tex_color = vec(1, 1, 1, 1),
				---Amount of pixels to overlap in each direction
				tex_extend = vec(0, 0, 0, 0),
				---UV pixels starting at each edge to slice inwards
				tex_slice = vec(0, 0, 0, 0),
				---If set, virtually offsets the texture's position
				---@type Vector2
				tex_reg_pos = nil,
				---If set, virtually sets the texture's size
				---@type Vector2
				tex_reg_size = nil,

				---Border line weight at each edge
				border = vec(0, 0, 0, 0),
				---Border color
				---@type Vector3|Vector4
				border_color = vec(1, 1, 1, 1),
				---Border offset at each edge
				border_extend = vec(0, 0, 0, 0),

				---Text string
				label = "",
				---Text shadow state
				---@type boolean
				label_shadow = false,
				---Text outline state
				---@type boolean
				label_outline = false,
				---Text outline color
				label_outline_color = vec(1, 1, 1) / 8,
				---Text size
				label_size = 1,
				---Text margin
				label_margin = vec(0, 0, 0, 0),
				---Text alignment
				label_align = vec(0.5, 0.5),
			},
			hover = {},
			click = {},
			hover_click = {},
		},
		---@class FOXStencil.Element.State
		state = {
			---This element's visibility state
			---@type boolean
			visible = true,
			---This element's calculated position relative to its parent
			pos = vec(0, 0),
			---Position on this element that was hovered
			hover_pos = vec(0, 0),
			---Interlaced layer used to prevent z fighting elements
			layer = 0,

			---This element's calculated size
			size = vec(0, 0),
			---This element's calculated minimum size
			size_min = vec(0, 0),
			---This element's calculated maximum size
			size_max = vec(0, 0),

			---Bounding box position relative to its parent
			bound_pos = vec(0, 0),
			---Bounding box size
			bound_size = vec(0, 0)
		},

		root = root,
		parn = parn,
		sibl = sibl,
		---@type FOXMap<integer, FOXStencil.Element>
		chld = require("./map")(),

		skip = {
			---@type boolean
			layout = false,
			---@type boolean
			redraw = false,
		},
	}, class)
	self.layers = {
		require("./layers/slice")(self),
		require("./layers/border")(self),
		require("./layers/label")(self),
	}

	local props = self.props
	setmetatable(props.hover, { __index = props.normal })
	setmetatable(props.click, { __index = props.normal })
	setmetatable(props.hover_click, {
		__index = function(_, k)
			return rawget(props.hover, k) or rawget(props.click, k) or props.normal[k]
		end,
	})

	return self
end

---@param props FOXStencil.Element.Props?
---@return FOXStencil.Element
function class:newElement(props)
	local elem = new(
		self.part:newPart("elem"),
		self.root,
		self ~= self.root and self or nil,
		self.chld
	):setProps(props or {})
	self.chld:push(elem)
	return elem
end

---@generic self
---@param self self|FOXStencil.Element
---@param props FOXStencil.Element.Props
---@param group FOXStencil.Element.Props.Group?
---@return self
function class:setProps(props, group)
	group = group or "normal"
	for k, v in pairs(props) do
		local t = type(v)
		if t == "table" then
			v = { table.unpack(v) }
		elseif t:find("^Vector") then
			v = v:copy()
		end
		self.props[group][k] = v
	end
	return self
end

local group_id = {
	[0] = "normal",
	"hover",
	"click",
	"hover_click",
}

---@param group FOXStencil.Element.Props.Group?
---@return FOXStencil.Element.Props
function class:getProps(group)
	return self.props[group or group_id[self.group]]
end

---Removes this element from its parent
---@generic self
---@param self self|FOXStencil.Element
---@return self
function class:remove()
	self:queue()
	self.sibl:remove(self.sibl:getKey(self) --[[@as integer]])
	self.sibl = require("./map")() --[[@as FOXMap<integer, FOXStencil.Element>]]:push(self)
	self.part:remove()
	self.parn = nil
	self.root = nil
	return self
end

---Makes this element a child of the given element
---@generic self
---@param self self|FOXStencil.Element
---@param elem FOXStencil.Element
---@param pos integer?
---@return self
function class:moveTo(elem, pos)
	self.sibl[1]:queue()
	if pos then
		elem.chld:insert(math.clamp(pos, 1, #elem.chld), self:remove())
	else
		elem.chld:push(self:remove())
	end
	self.parn = elem
	self.root = elem.root
	self.sibl = elem.chld
	self.sibl[1]:queue()
	self.part:moveTo(elem.part)
	self.root:render()
	return self
end

---Adds the given element as a child of this element
---@generic self
---@param self self|FOXStencil.Element
---@param elem FOXStencil.Element
---@param pos integer?
---@return self
function class:addChild(elem, pos)
	elem:moveTo(self, pos)
	return self
end

---Moves this element through its siblings by a given interval
---@generic self
---@param self self|FOXStencil.Element
---@return self
function class:drop(interval)
	local sibl = self.sibl
	local key = sibl:getKey(self) --[[@as integer]]
	sibl:insert(math.clamp(key + interval, 1, #sibl), sibl:remove(key) --[[@as FOXStencil.Element]])
	sibl[math.clamp(key - math.abs(interval), 1, #sibl)]:queue()
	return self
end

---Swaps an element with another element
---@generic self
---@param self self|FOXStencil.Element
---@param elem FOXStencil.Element
---@return self
function class:swap(elem)
	local parn = self.parn --[[@as FOXStencil.Element]]
	local key = self.sibl:getKey(self)
	self:moveTo(elem.parn, elem.sibl:getKey(elem))
	elem:moveTo(parn, key)
	return self
end

---@generic self
---@param self self|FOXStencil.Element
---@return self
function class:queue()
	-- Queue late siblings up parent tree

	-- TODO: Potential optimization here would be to check if the element changed size along or against layout and only queue elements on that axis

	local tree = self
	repeat
		for i = tree.sibl:getKey(tree), #tree.sibl do
			tree.sibl[i].skip.layout = false
		end
		tree.skip.redraw = false
		tree = tree.parn
	until not tree

	return self
end

---@generic self
---@param self self|FOXStencil.Element
---@param forced boolean?
---@return self
function class:draw(forced)
	self.part:pos(-self.state.pos:augmented(self.props.layer)):visible(self.state.visible)
	if self.skip.redraw and not forced then return self end

	for i = 1, #self.layers do
		self.layers[i]:draw()
	end

	return self
end

return { new = new, class = class }
