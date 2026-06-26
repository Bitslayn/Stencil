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

---@class FOXStencil.Pointer
local default_pointer = {
	---Position on this element being hovered
	elem_pos = vec(0, 0),
	---Position on the screen being hovered
	root_pos = vec(0, 0),
	---Position in the world being hovered
	wrld_pos = vec(0, 0, 0),
}

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

		---@type FOXStencil.Pointer
		pointer = setmetatable({}, { __index = default_pointer }),
	}
	---@package
	---@type FOXStencil.Screen
	self.root = self
	return setmetatable(self, class)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Press ♡˚
--==============================================================================================================================

local was_pressed = false

---@type boolean
local mouse_press
function events.mouse_press(_, state)
	mouse_press = state ~= 0 or false
end

---Returns if the host is pressing the screen
---@return boolean state
---@return boolean change
local function get_screen_press()
	if was_pressed == mouse_press then return mouse_press, false end
	was_pressed = mouse_press

	return mouse_press, true
end

---Returns if the viewer started swinging or using an item
---@return boolean state
---@return boolean change
local function get_world_press()
	local viewer = client.getViewer()

	local swing_time = viewer:getSwingTime()
	local is_pressed = 0 < swing_time and swing_time < 3 or viewer:isUsingItem()
	if was_pressed == is_pressed then return is_pressed, false end
	was_pressed = is_pressed

	return is_pressed, true
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

	local hover, press_state, press_changed
	if mode == "GUI" then
		hover = interact.screen_hover
		press_state, press_changed = get_screen_press()
	elseif mode == "WORLD" then
		hover = interact.world_hover
		press_state, press_changed = get_world_press()
	elseif mode == "SKULL" then
		hover = interact.skull_hover
		press_state, press_changed = get_world_press()
	end

	local hovered
	for i = #self.chld, 1, -1 do
		local elem = self.chld[i]
		---@diagnostic disable-next-line: param-type-mismatch
		hovered = hover(elem, press_state, press_changed, block)
		if hovered then break end
	end

	if not hovered then
		interact.reset(self, was_pressed)
	end

	-- Draw screen elements

	for i = 1, #self.chld do
		local elem = self.chld[i]
		layout.restore(elem)

		layout.size(elem, 1)
		layout.grow(elem, 1)
		layout.size(elem, 2)
		layout.grow(elem, 2)
		layout.position(elem)

		layout.draw(elem, (i - 1) * 2, 1 / #self.chld)
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
