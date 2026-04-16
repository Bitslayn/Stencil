---@type FOXStencil.Element
local super = require("../element/class").class

---@class FOXStencil.Layout: FOXStencil.Element
local class = {}
---@package
function class:__index(k)
	return class[k] or super[k]
end

---@param part ModelPart
---@return FOXStencil.Layout
local function new(part)
	---@class FOXStencil.Layout
	---@field clicked FOXStencil.Element?
	---@field hovered FOXStencil.Element?
	local self = {
		part = part:newPart("root"):scale(1, 1, 0.2),
		chld = require("../element/map")(), --[[@as FOXMap<integer, FOXStencil.Element>]]
	}
	self.root = self
	return setmetatable(self, class)
end

local layout = require("./render/layout")
local interact = require("./render/interact")

---@return self
function class:render()
	local is_screen = self.part:partToWorldMatrix() == matrices.scale4(1 / 16)

	-- Do interaction

	local hovering = false

	local len = #self.chld
	for i = len, 1, -1 do
		local elem = self.chld[i]

		local hovered
		if is_screen then
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

	for i = 1, len do
		local elem = self.chld[i]
		layout.restore(elem)

		layout.size(elem, 1)
		layout.grow(elem, 1)
		layout.size(elem, 2)
		layout.grow(elem, 2)
		layout.position(elem)

		layout.draw(elem, (i - 1) * 4, 1 / len)
	end

	return self
end

return { new = new, class = class }
