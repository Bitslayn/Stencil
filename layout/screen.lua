---@type FOXStencil.Element
local super = require("./element")

---@class FOXStencil.Screen: FOXStencil.Element
local class = {}
---@package
function class:__index(k)
	return class[k] or super[k]
end

local layout = require("./core/layout")
local interact = require("./core/interact")

---@param block BlockState?
---@return self
function class:render(block)
	local is_screen = self.part:partToWorldMatrix() == matrices.scale4(1 / 16)

	-- Do interaction

	local hovering = false

	local len = #self.chld
	for i = len, 1, -1 do
		local elem = self.chld[i]

		local hovered
		if type(block) == "BlockState" then
			hovered = interact.skull_hover(elem, block)
		elseif is_screen then
			hovered = interact.screen_hover(elem)
		else
			hovered = interact.world_hover(elem)
		end

		if hovered then
			hovering = true
			break
		end
	end

	if not hovering then
		interact.reset(self)
	end

	-- Draw screen

	-- local t = client.getSystemTime()
	for i = 1, len do
		local elem = self.chld[i]
		layout.restore(elem) -- 31.697

		layout.size(elem, 1) -- 38.597μs (Text wrapping)
		layout.grow(elem, 1) -- 38.597μs
		layout.size(elem, 2) -- 62.197μs (Text wrapping)
		layout.grow(elem, 2) -- 37.567μs
		layout.position(elem) -- 32.497μs < 59.197μs Optimized+

		layout.draw(elem, (i - 1) * 2, 1 / len) -- 655.897μs
	end
	-- host:actionbar(tostring(client.getSystemTime() - t))

	return self
end

local map = require("./types/map")

---@param part ModelPart
---@return FOXStencil.Screen
return function(part)
	---@class FOXStencil.Screen
	---@field clicked FOXStencil.Element?
	---@field hovered FOXStencil.Element?
	local self = {
		part = part:newPart("root"):scale(1, 1, 0.2),
		chld = map(), --[[@as FOXMap<integer, FOXStencil.Element>]]
		elem_dict = {}
	}
	self.root = self
	return setmetatable(self, class)
end
