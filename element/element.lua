---@class FOXStencil.Element
local class = {}
---@package
class.__index = class

---@class FOXStencil.Props
---@field click fun(rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean)?
---@field hover fun(rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean, changed: boolean)?
local props_default = {
	---This element's preferred offset position
	pos = vec(0, 0),
	---State defines whether this element should be absolutely positioned and draw through its siblings
	absolute_pos = false,

	---This element's preferred size
	size = vec(0, 0),
	---This element's minimum size
	size_min = vec(0, 0),
	---This element's maximum size
	size_max = vec(math.huge, math.huge),
	---States define whether this element is allowed to dynamically scale within min and max bounds
	---@type [boolean, boolean]
	size_flex = { false, false },

	---Child padding, or space around children
	padding = vec(0, 0, 0, 0),
	---Child gap, or space between children
	gap = 0,
	---Child layout direction, false is horizontal and true is vertical
	---@type boolean
	vertical = false,
	---Child gravity or alignment. (0, 0) is top-left and (1, 1) is bottom-right
	align = vec(0, 0),

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
	---Text wrap
	---@type boolean
	label_wrap = true,
}

---@package
props_default.__index = props_default

-- immediate, parents, siblings, children

local IMMEDIATE = { immediate = true }
local PARENTS = { parents = true }
local SIBLINGS = { parents = true, siblings = true }
local CHILDREN = { parents = true, children = true }
local ALL = { parents = true, siblings = true, children = true }

---@type table<string, table<string, boolean>>
local queue_shape = {
	pos = SIBLINGS,
	absolute_pos = SIBLINGS,

	size = SIBLINGS,
	size_min = SIBLINGS,
	size_max = SIBLINGS,
	size_flex = SIBLINGS,

	padding = ALL,
	gap = ALL,
	vertical = ALL,
	align = ALL,

	tex = IMMEDIATE,
	tex_uv_pos = IMMEDIATE,
	tex_uv_size = IMMEDIATE,
	tex_color = IMMEDIATE,
	tex_extend = IMMEDIATE,
	tex_slice = IMMEDIATE,
	tex_reg_pos = IMMEDIATE,
	tex_reg_size = IMMEDIATE,

	border = IMMEDIATE,
	border_color = IMMEDIATE,
	border_extend = IMMEDIATE,

	label = SIBLINGS,
	label_shadow = IMMEDIATE,
	label_outline = IMMEDIATE,
	label_outline_color = IMMEDIATE,
	label_size = SIBLINGS,
	label_margin = SIBLINGS,
	label_align = IMMEDIATE,
	label_wrap = SIBLINGS,
}

---@param part ModelPart
---@param root FOXStencil.Screen
---@param parn FOXStencil.Element?
---@param sibl FOXMap<integer, FOXStencil.Element>
---@return FOXStencil.Element
local function new(name, part, root, parn, sibl)
	local basic = setmetatable({}, props_default)
	local hover = setmetatable({}, { __index = basic })
	local click = setmetatable({}, { __index = basic })
	local mixed = setmetatable({}, {
		__index = function(_, k)
			return rawget(click, k) or hover[k]
		end,
	}) --[[@as FOXStencil.Props]]

	---@class FOXStencil.Element
	local self = setmetatable({
		part = part,
		name = name,

		props = basic,
		props_groups = {
			basic, -- None
			hover, -- ID: 1
			click, -- ID: 2
			mixed, -- Both 1 and 2
		},
		props_groups_shape = {
			basic = {},
			hover = {},
			click = {},
			mixed = {},
		},
		props_groups_named = {
			basic = basic,
			hover = hover,
			click = click,
			mixed = mixed,
		},

		---@class FOXStencil.Element.State
		state = {
			---This element's visibility state
			---@type boolean
			visible = true,
			---This element's calculated position relative to its parent
			pos = vec(0, 0),
			---This element's position being calculated
			calc_pos = { 0, 0 },

			---Interlaced layer used to prevent z fighting elements
			layer = 0,

			---This element's calculated size
			size = vec(0, 0),
			---This element's size being calculated
			calc_size = { 0, 0 },
			---This element's calculated minimum size
			size_min = vec(0, 0),
			---This element's minimum size being calculated
			calc_size_min = { 0, 0 },
			---This element's calculated maximum size
			size_max = vec(0, 0),
			---This element's minimum size being calculated
			calc_size_max = { 0, 0 },

			---Precalculated size of child elements with gap along direction
			child_span = 0,
			---Precalculated element axis priority order
			elem_axis = { 1, 2 },
			---Precalculated element padding priority order
			elem_pad = { { 0, 0 }, { 0, 0 } },

			---Position on this element that was hovered
			hover_pos = vec(0, 0),
			---This element's bounding box position
			bound_pos = vec(0, 0),
			---This element's bounding box size
			bound_size = vec(0, 0),

			mouse_mode = 1,
		},

		root = root,
		parn = parn,
		sibl = sibl,
		---@type FOXMap<integer, FOXStencil.Element>
		chld = require("./map")(),

		queued = true,
	}, class)

	self.layers = {
		require("./layers/slice")(self),
		require("./layers/border")(self),
		require("./layers/label")(self),
	}

	return self
end

---@param name string
---@param props FOXStencil.Props?
---@return FOXStencil.Element
function class:newElement(name, props)
	local elem = new(
		name,
		self.part:newPart("elem"),
		self.root,
		self ~= self.root and self or nil,
		self.chld
	):setProps(props or {})
	self.chld:push(elem)
	return elem
end

---@generic t
---@param a `t`
---@param b t
local function merge(a, b)
	for k, v in next, b do
		a[k] = v
	end
end

---@generic self
---@param self self|FOXStencil.Element
---@param props FOXStencil.Props
---@param group string?
---@return self
function class:setProps(props, group)
	-- Check group before queuing!

	---@type table<string, boolean>
	local shape = {}

	group = group or "basic"
	local p = self.props_groups_named[group]

	for k, v in next, props --[[@as table<string, unknown>]] do
		local diff = false

		local t = type(v)
		if t == "table" then
			v = { v[1], v[2] }
			diff = p[k][1] ~= v[1] or p[k][2] ~= v[2]
		elseif t:find("^Vector") then
			v = v:copy()
		end

		diff = diff or p[k] ~= v
		p[k] = v

		if diff and queue_shape[k] then
			merge(shape, queue_shape[k])
		end
	end

	if p ~= self.props then return self end

	if shape.immediate then
		self:draw()
	end
	self:queue(shape)

	return self
end

---@generic self
---@param self self|FOXStencil.Element
---@param id integer
---@param state boolean
---@return self
function class:setPropsGroup(id, state)
	if state then
		self.state.mouse_mode = bit32.bor(self.state.mouse_mode - 1, id) + 1
	else
		local _id = bit32.bxor(id, #self.props_groups - 1)
		self.state.mouse_mode = bit32.band(self.state.mouse_mode - 1, _id) + 1
	end

	self.props = self.props_groups[self.state.mouse_mode]

	return self:draw()
end

---Removes this element from its parent
---@generic self
---@param self self|FOXStencil.Element
---@return self
function class:remove()
	self:queue(SIBLINGS)
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
	self.sibl[1]:queue(SIBLINGS)
	if pos then
		elem.chld:insert(math.clamp(pos, 1, #elem.chld), self:remove())
	else
		elem.chld:push(self:remove())
	end
	self.parn = elem
	self.root = elem.root
	self.sibl = elem.chld
	self.sibl[1]:queue(SIBLINGS)
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
	sibl[math.clamp(key - math.abs(interval), 1, #sibl)]:queue(SIBLINGS)
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
---@param shape {immediate: boolean, parents: boolean, siblings: boolean, children: boolean}
---@return self
function class:queue(shape)
	-- Queue children

	if shape.children then
		for i = 1, #self.sibl do
			self.sibl[i].queued = true
		end
	end

	-- Queue siblings up parent tree

	local tree = self
	if shape.parents then
		repeat
			if shape.siblings then
				for i = 1, #tree.sibl do
					tree.sibl[i].queued = true
				end
			else
				tree.queued = true
			end
			tree = tree.parn
		until not tree
	elseif not shape.immediate then
		tree.queued = true
	end

	return self
end

---@generic self
---@param self self|FOXStencil.Element
---@return self
function class:draw()
	local state = self.state
	local extend = self.props.tex_extend
	state.bound_pos = state.pos - extend.wx --[[@as Vector2]]
	state.bound_size = state.size + extend.wx + extend.yz --[[@as Vector2]]

	self.part:pos(-self.state.pos:augmented(self.state.layer)):visible(self.state.visible)

	for i = 1, #self.layers do
		self.layers[i]:draw()
	end

	return self
end

---@generic self
---@param self self|FOXStencil.Element
---@param state boolean?
---@return self
function class:visible(state)
	state = state == nil and true or state --[[@as boolean]]
	self.state.visible = state
	return self:queue(ALL)
end

return class
