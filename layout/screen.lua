--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@class FOXStencil.Screen
local class = {}
---@package
class.__index = class

local map = require("./types/map")

---@param part ModelPart
---@return FOXStencil.Screen
local function new(part)
	---@class FOXStencil.Screen
	---@field clicked FOXStencil.Element?
	---@field hovered FOXStencil.Element?
	local self = {
		part = part:newPart("root"):scale(1, 1, 0.2),
		---@type FOXMap<integer, FOXStencil.Element>
		chld = map(),
		---@type table<string, FOXMap<integer, FOXStencil.Element>>
		chld_dict = {},
	}
	self.root = self
	return setmetatable(self, class)
end

local layout = require("./core/layout")
local interact = require("./core/interact")

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Self ♡˚
--==============================================================================================================================

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

	for i = 1, len do
		local elem = self.chld[i]
		layout.restore(elem)

		layout.size(elem, 1)
		layout.grow(elem, 1)
		layout.size(elem, 2)
		layout.grow(elem, 2)
		layout.position(elem)

		layout.draw(elem, (i - 1) * 2, 1 / len)
	end

	return self
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Children ♡˚
--==============================================================================================================================

---@param name string
---@return FOXStencil.Element
function class:getElement(name)
	return self.chld_dict[name][1]
end

local element = require("./element")

---@param name string
---@return FOXStencil.Element
function class:newElement(name)
	return element.newElement(self, name)
end

local assets = require("./../assets/assets") --[[@as FOXStencil.Assets]]

---@generic FOXStencil.Widget
---@param name string
---@param widget fun(parent: FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Widget
---@return FOXStencil.Widget
function class:newWidget(name, widget)
	return widget(self, name, assets)
end

return new

--#ENDREGION
