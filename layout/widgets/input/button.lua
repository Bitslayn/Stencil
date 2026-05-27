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

---@type FOXStencil.Element.Events.Press
local function press(elem)
	local extend_pos = vec(0, 0)
	local extend_size = elem.state.size

	---@type FOXStencil.Slice
	local background = elem:getLayer("background")
	background:setStyles({
		pos = extend_pos,
		size = extend_size,

		uv_pos = vec(4, 0),
		uv_size = vec(5, 5),
		slice = vec(2, 2, 2, 2),
	})

	---@type FOXStencil.Label
	local label = elem:getLayer("label")
	label:setStyles({
		pos = extend_pos + vec(3, 3),
	})

	---@type FOXStencil.Border
	local outline = elem:getLayer("outline")
	outline:setStyles({
		pos = extend_pos,
		size = extend_size,
	})

	elem.widg.press(elem.widg)
end

---@type FOXStencil.Element.Events.Release
local function release(elem)
	local extend_pos = vec(0, -2)
	local extend_size = elem.state.size + vec(0, 2)

	---@type FOXStencil.Slice
	local background = elem:getLayer("background")
	background:setStyles({
		pos = extend_pos,
		size = extend_size,

		uv_pos = vec(0, 0),
		uv_size = vec(5, 7),
		slice = vec(2, 2, 4, 2),
	})

	---@type FOXStencil.Label
	local label = elem:getLayer("label")
	label:setStyles({
		pos = extend_pos + vec(3, 3),
	})

	---@type FOXStencil.Border
	local outline = elem:getLayer("outline")
	outline:setStyles({
		pos = extend_pos,
		size = extend_size,
	})

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
	return client.getTextDimensions(elem.widg.styles.text, (width - 6) / size) * size + 6
end

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	---@type FOXStencil.Slice
	local background = elem:getLayer("background")
	background:setStyles({
		color = elem.widg.styles.color,
		size = elem.state.size + vec(0, 2),
	})

	---@type FOXStencil.Label
	local label = elem:getLayer("label")
	label:setStyles({
		text = elem.widg.styles.text,
		width = elem.state.size.x - 6,
	})

	---@type FOXStencil.Border
	local outline = elem:getLayer("outline")
	outline:setStyles({
		size = elem.state.size + vec(0, 2),
	})
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Builder ♡˚
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

	elem.events.press = press
	elem.events.release = release
	elem.events.hover = hover
	elem.events.wrap = wrap
	elem.events.draw = draw

	draw(elem)

	return setmetatable(widg, obj)
end

--#ENDREGION
