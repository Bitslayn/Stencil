--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@class FOXStencil.Screen.Index
---@field [string] FOXStencil.Element

---@class FOXStencil.Screen: FOXStencil.Screen.Index
local class = {}
---@package
function class:__index(k)
	return class[k] or self:getElement(k)
end

local map = require("./types/map")

---@param part ModelPart
---@return FOXStencil.Screen
local function new(part)
	---@class FOXStencil.Screen
	local self = {
		---@package
		---@type ModelPart
		part = part:newPart("root"):scale(1, 1, 0.2),
		---@package
		---@type FOXMap<integer, FOXStencil.Element>
		chld = map(),
		---@package
		---@type table<string, FOXMap<integer, FOXStencil.Element>>
		chld_dict = {},

		---@package
		---@type FOXStencil.Element?
		pressed = nil,
		---@package
		---@type FOXStencil.Element?
		hovered = nil,
	}
	---@package
	---@type FOXStencil.Screen
	self.root = self
	return setmetatable(self, class)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Self ♡˚
--==============================================================================================================================

local interact = require("./core/interact")
local layout = require("./core/layout")

---@param mode "GUI"|"WORLD"|"SKULL"
---@param block BlockState?
---@return self
function class:render(mode, block)
	-- Interact with screen elements

	local len = #self.chld
	local hovered
	for i = len, 1, -1 do
		local elem = self.chld[i]

		if mode == "GUI" then
			hovered = interact.screen_hover(elem)
		elseif mode == "WORLD" then
			hovered = interact.world_hover(elem)
		elseif mode == "SKULL" and block then
			hovered = interact.skull_hover(elem, block)
		end

		if hovered then break end
	end

	if not hovered then
		interact.reset(self)
	end

	-- Draw screen elements

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

---@return self
function class:remove()
	self.part:remove()
	return self
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Children ♡˚
--==============================================================================================================================

---@param name string
---@return FOXStencil.Element?
function class:getElement(name)
	if not self.chld_dict[name] then return end
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
