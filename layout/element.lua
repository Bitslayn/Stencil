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
	---This element's size
	size = vec(0, 0),
	---This element's minimum size
	size_min = vec(0, 0),
	---This element's maximum size
	size_max = vec(math.huge, math.huge),

	---Child padding, or space around children
	padding = vec(0, 0, 0, 0),
	---Child gap, or space between children
	gap = 0,
	---Child layout direction
	---@type "HORIZONTAL"|"VERTICAL"
	direction = "HORIZONTAL",
	---Child gravity or alignment. (0, 0) is top-left and (1, 1) is bottom-right
	align = vec(0, 0),

	---Element visibility
	visible = true,
}

---@class FOXStencil.Element.State
local default_state = {
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
	---If this element is flexing in each direction
	size_flex = { false, false },

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
---@alias FOXStencil.Element.Events.Wrap fun(elem: FOXStencil.Element, width: number): Vector2?
---@alias FOXStencil.Element.Events.Draw fun(elem: FOXStencil.Element)

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

	---Called twice while this element is wrapping
	---
	---The returned vector will be used as the size of this element
	---@type FOXStencil.Element.Events.Wrap
	wrap = function() end,
	---Called whenever this element changes shape
	---@type FOXStencil.Element.Events.Draw
	draw = function() end,
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
		widg = {},

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
		for i = 1, #self.chld do
			self.chld[i].queued = true
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

local assets = require("./core/assets")

---@generic FOXStencil.Widget
---@param name string
---@param widget fun(parent: FOXStencil.Element, name: string, assets: FOXStencil.Assets): FOXStencil.Widget
---@return FOXStencil.Widget
function class:newWidget(name, widget)
	return widget(self, name, assets)
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
	-- Remove this element from its siblings

	local key = self.sibl:getKey(self) --[[@as integer]]
	self.sibl:remove(key)

	-- Make this element an orphan

	self.sibl = require("./core/map")() --[[@as FOXMap<integer, FOXStencil.Element>]]:push(self) -- TODO Localize
	self.part:remove()
	self.parn = nil
	self.root = nil

	-- TODO test with queue

	return self
end

---Makes this element a child of the given element
---@generic self
---@param self self|FOXStencil.Element
---@param elem FOXStencil.Element
---@return self
function class:moveTo(elem)
	-- Move this element

	local key = self.sibl:getKey(self) --[[@as integer]]
	local val = self.sibl:remove(key) --[[@as FOXStencil.Element]]
	elem.chld:push(val)

	-- Reparent

	self.sibl = elem.chld
	self.part:moveTo(elem.part)
	self.parn = elem
	self.root = elem.root

	-- TODO test with queue

	return self
end

---Sets this element's index
---@generic self
---@param self self|FOXStencil.Element
---@return self
function class:setIndex(index)
	assert(1 <= index and index <= #self.sibl, "Index out of range for setIndex") -- TODO assertion level

	-- Removes the element, then inserts at the desired position

	local key = self.sibl:getKey(self) --[[@as integer]]
	local val = self.sibl:remove(key) --[[@as FOXStencil.Element]]
	self.sibl:insert(index, val)

	-- TODO test with queue

	return self:queue()
end

return class

--#ENDREGION
