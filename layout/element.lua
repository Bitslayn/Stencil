--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@class FOXStencil.Element
local class = {}
---@package
class.__index = class

---@class FOXStencil.Element.Props
local default_props = {
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
	size_flex = { false, false }, -- TODO merge with size

	---Child padding, or space around children
	padding = vec(0, 0, 0, 0),
	---Child gap, or space between children
	gap = 0,
	---Child layout direction, false is horizontal and true is vertical
	---@type boolean
	vertical = false,
	---Child gravity or alignment. (0, 0) is top-left and (1, 1) is bottom-right
	align = vec(0, 0),

	---Element visibility
	visible = true,
}

---@class FOXStencil.Element.State
local default_state = {
	-- TODO remove raw_ fields

	---This element's visibility state TODO Move to props
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

	screen_pos = vec(0, 0),
	world_pos = vec(0, 0, 0),
}

---@alias FOXStencil.Element.Events.Press fun(elem: FOXStencil.Element, pos: Vector2)
---@alias FOXStencil.Element.Events.Release fun(elem: FOXStencil.Element, pos: Vector2)
---@alias FOXStencil.Element.Events.Hover fun(elem: FOXStencil.Element, pos: Vector2, state: boolean)
---@alias FOXStencil.Element.Events.Redraw fun(elem: FOXStencil.Element)

---@class FOXStencil.Element.Events
local default_events = {
	--TODO Need events for sizing text

	---Called on mouse click, swing, or item use action
	---@type FOXStencil.Element.Events.Press
	press = function() end,
	---Called when mouse click, swing, or item use action expires
	---@type FOXStencil.Element.Events.Release
	release = function() end,
	---Called while moused over or looked at
	---@type FOXStencil.Element.Events.Hover
	hover = function() end,
	
	---Called whenever this element changes shape
	---@type FOXStencil.Element.Events.Redraw
	redraw = function() end,
}

---@param part ModelPart
---@param root FOXStencil.Screen
---@param parn FOXStencil.Element?
---@param sibl FOXMap<integer, FOXStencil.Element>
---@return FOXStencil.Element
local function new(part, root, parn, sibl)
	---@class FOXStencil.Element
	local self = setmetatable({
		part = part,

		props = setmetatable({}, { __index = default_props }),
		state = setmetatable({}, { __index = default_state }),
		events = setmetatable({}, { __index = default_events }),

		---@type FOXStencil.Layer[]
		layers = {},

		root = root,
		parn = parn,
		sibl = sibl,
		---@type FOXMap<integer, FOXStencil.Element>
		chld = require("./core/map")(),

		queued = true,
	}, class)

	return self
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Self ♡˚
--==============================================================================================================================

local copy = require("./core/parser").copy

---@generic self
---@param self self|FOXStencil.Element
---@param props FOXStencil.Element.Props
---@return self
function class:setProps(props)
	if not copy(props, self.props) then return self end

	self:queue()

	return self
end

---@generic self
---@param self self|FOXStencil.Element
---@return self
function class:queue()
	local shape = { parents = true, siblings = true, children = true }

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

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Children ♡˚
--==============================================================================================================================

---@param name string
---@return FOXStencil.Element
function class:getElement(name)

end

---@generic FOXStencil.Layer
---@param name string
---@return FOXStencil.Layer
function class:getLayer(name)
	return self.layers[name]
end

---@param name string
---@return FOXStencil.Element
function class:newElement(name)
	local elem = new(
		self.part:newPart(name),
		self.root,
		self ~= self.root and self or nil,
		self.chld
	)
	self.chld:push(elem)
	return elem
end

local provider = require("./core/provider")

---@generic FOXStencil.Widget
---@param name string
---@param widget fun(parent: FOXStencil.Element, name: string, layers: FOXStencil.Layers, widgets: FOXStencil.Widgets): FOXStencil.Widget
---@return FOXStencil.Widget
function class:newWidget(name, widget)
	return widget(self, name, provider.layers, provider.widgets)
end

---@generic FOXStencil.Layer
---@param name string
---@param layer fun(part: ModelPart): FOXStencil.Layer
---@return FOXStencil.Layer
function class:newLayer(name, layer)
	assert(not self.layers[name]) -- TODO Multiple layers with the same name should remove the previous layer
	self.layers[name] = layer(self.part)
	return self.layers[name]
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Parent ♡˚
--==============================================================================================================================

---Removes this element from its parent
---@generic self
---@param self self|FOXStencil.Element
---@return self
function class:remove()
	self:queue()
	self.sibl:remove(self.sibl:getKey(self) --[[@as integer]])
	self.sibl = require("./core/map")() --[[@as FOXMap<integer, FOXStencil.Element>]]:push(self)
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

return class

--#ENDREGION
