--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---Generates a button widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Button.Generator fun(parent: FOXStencil.Element, name: string, layers: FOXStencil.Layers, widgets: FOXStencil.Widgets): FOXStencil.Button

---@class FOXStencil.Widgets
---@field button FOXStencil.Button.Generator

---@alias FOXStencil.Button.Press fun(widg: FOXStencil.Button)
---@alias FOXStencil.Button.Release fun(widg: FOXStencil.Button)

---@class FOXStencil.Button
---@field elem FOXStencil.Element
---@field press FOXStencil.Button.Press
---@field release FOXStencil.Button.Release
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Button.Styles
local default_styles = {
	text = "Button",
	color = vec(1, 1, 1),
}

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	local extend_pos = vec(0, -elem.widg.extend)
	local extend_size = elem.state.size + vec(0, elem.widg.extend)

	---@type FOXStencil.Slice
	local background = elem:getLayer("background")
	background:setStyles({
		pos = extend_pos,
		size = extend_size,
		color = elem.widg.styles.color,

		uv_pos = elem.widg.pressed and vec(4, 0) or vec(0, 0),
		uv_size = elem.widg.pressed and vec(5, 5) or vec(5, 7),
		slice = elem.widg.pressed and vec(2, 2, 2, 2) or vec(2, 2, 4, 2),
	})

	---@type FOXStencil.Label
	local label = elem:getLayer("label")
	label:setStyles({
		pos = extend_pos + vec(3, 3),

		text = elem.widg.styles.text,
		width = elem.state.size.x - 6,
	})

	---@type FOXStencil.Border
	local outline = elem:getLayer("outline")
	outline:setStyles({
		pos = extend_pos,
		size = extend_size,
	})
end

---@type FOXStencil.Element.Events.Press
local function press(elem)
	elem.widg.extend = 0
	elem.widg.pressed = true
	draw(elem)
	elem.widg.press(elem.widg)
end

---@type FOXStencil.Element.Events.Release
local function release(elem)
	elem.widg.extend = 2
	elem.widg.pressed = false
	draw(elem)
	elem.widg.release(elem.widg)
end

---@type FOXStencil.Element.Events.Hover
local function hover(elem, _, state)
	---@type FOXStencil.Border
	local outline = elem:getLayer("outline")
	outline:setStyles({
		visible = state,
	})
end

---@type FOXStencil.Element.Events.Wrap
local function wrap(elem, width)
	---@type FOXStencil.Label
	local label = elem:getLayer("label")
	local size = label.styles.size / 9
	return client.getTextDimensions(elem.widg.styles.text, (width - 6) / size) * size + vec(6, 6)
end


--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

local copy = require("./../../core/parser").copy

---Sets the given styles
---@param styles FOXStencil.Button.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.elem.widg.styles) then
		draw(self.elem)
	end

	return self
end

---Sets the function to run when the button is pressed
---@param func FOXStencil.Button.Press
---@return self
function obj:onPress(func)
	assert(type(func) == "function", "A") -- TODO
	self.press = func
	return self
end

---Sets the function to run when the button is released
---@param func FOXStencil.Button.Release
---@return self
function obj:onRelease(func)
	assert(type(func) == "function", "A") -- TODO
	self.release = func
	return self
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Builder ♡˚
--==============================================================================================================================

---@param parent FOXStencil.Element
---@param layers FOXStencil.Layers
---@param widgets FOXStencil.Widgets
return function(parent, name, layers, widgets)
	local elem = parent:newElement(name):setProps({
		size = vec(-1, -1),
	})

	---@class FOXStencil.Button
	local widg = { elem = elem }
	elem.widg = widg

	widg.press = function() end
	widg.release = function() end
	widg.extend = 2

	widg.styles = setmetatable({}, { __index = default_styles })

	elem:newLayer("background", layers.slice):setStyles({
		pos = vec(0, -2),
		texture = textures["assets.textures.ui"],
		uv_pos = vec(0, 0),
		uv_size = vec(5, 7),
		slice = vec(2, 2, 4, 2),
	})

	elem:newLayer("label", layers.label):setStyles({
		pos = vec(3, 1),
		text = "Button",
	})

	elem:newLayer("outline", layers.border):setStyles({
		pos = vec(0, -2),
		visible = false,
	})

	elem.events.draw = draw
	elem.events.press = press
	elem.events.release = release
	elem.events.hover = hover
	elem.events.wrap = wrap

	draw(elem)

	return setmetatable(widg, obj)
end

--#ENDREGION
