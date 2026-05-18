---@class FOXStencil.Element
local class = {}
---@package
class.__index = class

---@class FOXStencil.Props
---@field click fun(rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean)?
---@field hover fun(rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean, changed: boolean)?
local props_default = {
	---This element's preferred offset position
	---@queue Immediate
	pos = vec(0, 0),
	---State defines whether this element should be absolutely positioned and draw through its siblings
	---@queue Siblings
	absolute_pos = false,

	---This element's preferred size
	---@queue Siblings
	size = vec(0, 0),
	---This element's minimum size
	---@queue Siblings
	size_min = vec(0, 0),
	---This element's maximum size
	---@queue Siblings
	size_max = vec(math.huge, math.huge),
	---States define whether this element is allowed to dynamically scale within min and max bounds
	---@queue Siblings
	---@type [boolean, boolean]
	size_flex = { false, false },

	---Child padding, or space around children
	---@queue Siblings
	padding = vec(0, 0, 0, 0),
	---Element margin, or space around element
	---@queue Siblings
	margin = vec(0, 0, 0, 0),
	---Child gap, or space between children
	---@queue Siblings
	gap = 0,
	---Child layout direction, false is horizontal and true is vertical
	---@queue Siblings
	---@type boolean
	vertical = false,
	---Child gravity or alignment. (0, 0) is top-left and (1, 1) is bottom-right
	---@queue Children
	align = vec(0, 0),

	---Background texture
	---@queue Immediate
	---@type Texture
	tex = textures["FOXStencil_blank"],
	---UV position on the texture
	---@queue Immediate
	tex_uv_pos = vec(0, 0),
	---UV region on the texture
	---@queue Immediate
	tex_uv_size = vec(1, 1),
	---Background tint
	---@queue Immediate
	---@type Vector3|Vector4
	tex_color = vec(1, 1, 1, 1),
	---Amount of pixels to overlap in each direction
	---@queue Immediate
	tex_extend = vec(0, 0, 0, 0),
	---UV pixels starting at each edge to slice inwards
	---@queue Immediate
	tex_slice = vec(0, 0, 0, 0),
	---If set, virtually offsets the texture's position
	---@queue Immediate
	---@type Vector2
	tex_reg_pos = nil,
	---If set, virtually sets the texture's size
	---@queue Immediate
	---@type Vector2
	tex_reg_size = nil,

	---Border line weight at each edge
	---@queue Immediate
	border = vec(0, 0, 0, 0),
	---Border color
	---@queue Immediate
	---@type Vector3|Vector4
	border_color = vec(1, 1, 1, 1),
	---Border offset at each edge
	---@queue Immediate
	border_extend = vec(0, 0, 0, 0),

	---Text string
	---@queue Siblings
	label = "",
	---Text shadow state
	---@queue Immediate
	---@type boolean
	label_shadow = false,
	---Text outline state
	---@queue Immediate
	---@type boolean
	label_outline = false,
	---Text outline color
	---@queue Immediate
	label_outline_color = vec(1, 1, 1) / 8,
	---Text size
	---@queue Siblings
	label_size = 1,
	---Text margin
	---@queue Siblings
	label_margin = vec(0, 0, 0, 0),
	---Text alignment
	---@queue Immediate
	label_align = vec(0.5, 0.5),
	---Text wrap
	---@queue Siblings
	---@type boolean
	label_wrap = true,
}

---@package
props_default.__index = props_default

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

		props = basic,
		props_groups = {
			basic, -- None
			hover, -- ID: 1
			click, -- ID: 2
			mixed, -- Both 1 and 2
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

-- TODO Type assert

---@generic self
---@param self self|FOXStencil.Element
---@param props FOXStencil.Props
---@param group string?
---@return self
function class:setProps(props, group)
	group = group or "basic"
	for k, v in next, props do
		local t = type(v)
		if t == "table" then
			v = { table.unpack(v) }
		elseif t:find("^Vector") then
			v = v:copy()
		end
		self.props_groups_named[group][k] = v
	end

	self:queue()

	return self
end

---@generic self
---@param self self|FOXStencil.Element
---@param id integer
---@param state boolean
---@return self
function class:togglePropsGroup(id, state)
	if state then
		self.state.mouse_mode = bit32.bor(self.state.mouse_mode - 1, id) + 1
	else
		local _id = bit32.bxor(id, #self.props_groups - 1)
		self.state.mouse_mode = bit32.band(self.state.mouse_mode - 1, _id) + 1
	end
	self.props = self.props_groups[self.state.mouse_mode]
	return self:queue()
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
	-- Queue siblings up parent tree

	-- TODO Flag queue reason and break if elements should already be queued by that reason
	-- TODO No but then what if queue was called twice? Would the flag stack?

	local tree = self
	repeat
		for i = 1, #tree.sibl do
			tree.sibl[i].skip.layout = false
			tree.sibl[i].skip.redraw = false
		end
		tree = tree.parn
	until not tree

	return self
end

---@generic self
---@param self self|FOXStencil.Element
---@param forced boolean?
---@return self
function class:draw(forced)
	local state = self.state
	local extend = self.props.tex_extend
	state.bound_pos = state.pos - extend.wx --[[@as Vector2]]
	state.bound_size = state.size + extend.wx + extend.yz --[[@as Vector2]]

	self.part:pos(-self.state.pos:augmented(self.state.layer)):visible(self.state.visible)
	if self.skip.redraw and not forced then return self end

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
	return self
end

return { new = new, class = class }
