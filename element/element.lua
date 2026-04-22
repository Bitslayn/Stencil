---@class FOXStencil.Element
local class = {}
---@package
class.__index = class
require("./layer/layer")(class)

---@param part ModelPart
---@param root FOXStencil.Layout
---@param parn FOXStencil.Element?
---@param sibl FOXMap<integer, FOXStencil.Element>
---@return FOXStencil.Element
local function new(part, root, parn, sibl)
	---@class FOXStencil.Element
	local self = setmetatable({
		part = part,

		group = 0,
		---@class FOXStencil.Props
		---@field click fun(self: FOXStencil.Element, rel_pos: Vector2, true_pos: Vector2, state: boolean)?
		---@field hover fun(self: FOXStencil.Element, rel_pos: Vector2, true_pos: Vector2, state: boolean, changed: boolean)?
		props = {
			---This element's visibility state
			---@type boolean
			visible = true,
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
		},
		---@class FOXStencil.State: FOXStencil.Props
		---@field hover_pos Vector2
		state = {},

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
	self.layers = {}

	setmetatable(self.state, { __index = self.props })

	return self
end

---@param props FOXStencil.Props?
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

---@param props FOXStencil.Props
---@return self
function class:setProps(props)
	for k, v in pairs(props) do
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

---Removes this element from its parent
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
---@param elem FOXStencil.Element
---@param pos integer?
---@return self
function class:addChild(elem, pos)
	elem:moveTo(self, pos)
	return self
end

---Moves this element through its siblings by a given interval
---@return self
function class:drop(interval)
	local sibl = self.sibl
	local key = sibl:getKey(self) --[[@as integer]]
	sibl:insert(math.clamp(key + interval, 1, #sibl), sibl:remove(key) --[[@as FOXStencil.Element]])
	sibl[math.clamp(key - math.abs(interval), 1, #sibl)]:queue()
	return self
end

---Swaps an element with another element
---@param elem FOXStencil.Element
---@return self
function class:swap(elem)
	local parn = self.parn --[[@as FOXStencil.Element]]
	local key = self.sibl:getKey(self)
	self:moveTo(elem.parn, elem.sibl:getKey(elem))
	elem:moveTo(parn, key)
	return self
end

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

---@return self
function class:draw()
	for i = 1, #self.layers do
		self.layers[i]:draw()
	end

	return self
end

return { new = new, class = class }
