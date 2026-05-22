---@class FOXStencil.Element
local class = {}
---@package
class.__index = class

---@class FOXStencil.Props
---@field click fun(rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean)?
---@field hover fun(rel_pos: Vector2, true_pos: Vector2, sound_pos: Vector3, state: boolean, changed: boolean)?
local default = {
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
}

-- immediate, parents, siblings, children

---@alias FOXStencil.QueueShape {immediate: boolean, parents: boolean, siblings: boolean, children: boolean}

local PARENTS = { parents = true }
local SIBLINGS = { parents = true, siblings = true }
local CHILDREN = { parents = true, children = true }
local ALL = { parents = true, siblings = true, children = true }

---@type table<string, table<string, boolean>|fun(old: any, new: any, elem: FOXStencil.Element): FOXStencil.QueueShape>
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
}

---@param part ModelPart
---@param root FOXStencil.Screen
---@param parn FOXStencil.Element?
---@param sibl FOXMap<integer, FOXStencil.Element>
---@return FOXStencil.Element
local function new(name, part, root, parn, sibl)
	---@class FOXStencil.Element
	local self = setmetatable({
		part = part,
		name = name,

		props = setmetatable({}, { __index = default }),

		---Called on mouse click, swing, or item use action
		---
		---The callback vector is the position on this element that was pressed
		---@type fun(pos: Vector2)
		press = function() end,
		---Called when mouse click, swing, or item use action expires
		---
		---The callback vector is the closest position on this element that was released
		---@type fun(pos: Vector2)
		release = function() end,
		---Called while moused over or looked at
		---@type fun(pos: Vector2)
		hover = function() end,
		---Called while pressed and hovered
		---
		---The callback vector is the position offset from when the element was first pressed
		---@type fun(offset: Vector2)
		drag = function() end,
		---Called whenever this element changes shape or position
		---@type fun()
		draw = function() end,

		--TODO Need events for sizing text

		---@class FOXStencil.Element.State
		state = {
			---This element's visibility state
			---@type boolean
			visible = true,
			---This element's calculated position relative to its parent
			pos = vec(0, 0),
			---This element's position being calculated
			raw_pos = { 0, 0 },

			---Interlaced layer used to prevent z fighting elements
			layer = 0,

			---This element's calculated size
			size = vec(0, 0),
			---This element's size being calculated
			raw_size = { 0, 0 },
			---This element's calculated minimum size
			size_min = vec(0, 0),
			---This element's minimum size being calculated
			raw_size_min = { 0, 0 },
			---This element's calculated maximum size
			size_max = vec(0, 0),
			---This element's minimum size being calculated
			raw_size_max = { 0, 0 },

			---Precalculated size of child elements with gap along direction
			child_span = 0,
			---Precalculated element axis priority order
			elem_axis = { 1, 2 },
			---Precalculated element padding priority order
			elem_pad = { { 0, 0 }, { 0, 0 } },

			---Position on this element that was hovered
			hover_pos = vec(0, 0),
		},

		root = root,
		parn = parn,
		sibl = sibl,
		---@type FOXMap<integer, FOXStencil.Element>
		chld = require("./map")(),

		queued = true,
	}, class)

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

---@generic FOXStencil.Layer
---@param layer fun(part: ModelPart): FOXStencil.Layer
---@return FOXStencil.Layer
function class:addLayer(layer)
	return layer(self.part)
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
---@return self
function class:setProps(props)
	-- Check group before queuing!

	---@type table<string, boolean>
	local shape = {}

	local p = self.props

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

		if diff then
			if type(queue_shape[k]) == "function" then
				merge(shape, queue_shape[k](p[k], v, self))
			elseif queue_shape[k] then
				merge(shape, queue_shape[k])
			end
		end

		p[k] = v
	end

	if p ~= self.props then return self end

	self:queue(shape)

	return self
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
---@param shape FOXStencil.QueueShape
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
---@param state boolean?
---@return self
function class:visible(state)
	state = state == nil and true or state --[[@as boolean]]
	self.state.visible = state
	return self:queue(ALL)
end

return class
