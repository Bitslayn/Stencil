--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a button widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Button.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Button

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
	---@type string
	text = "Button",
	---@type Vector3|Vector4
	color = vec(1, 1, 1),
}

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	local widg = elem.widg

	elem:setProps({
		size_min = vec(client.getTextDimensions(string.gsub(widg.styles.text, "%s", "\n"), 0).x + 6, 0),
	})

	local extend_pos = vec(0, -widg.extend)
	local extend_size = elem.state.size + vec(0, widg.extend)

	local background = elem:getLayer("background") --[[@as FOXStencil.Slice]]
	background:setStyles({
		pos = extend_pos,
		size = extend_size,
		color = widg.styles.color,

		uv_pos = widg.pressed and vec(4, 0) or vec(0, 0),
		uv_size = widg.pressed and vec(5, 5) or vec(5, 7),
		slice = widg.pressed and vec(2, 2, 2, 2) or vec(2, 2, 4, 2),
	})

	local label = elem:getLayer("label") --[[@as FOXStencil.Text]]
	label:setStyles({
		pos = extend_pos + vec(3, 3),

		text = widg.styles.text,
		width = elem.state.size.x - 6,
	})

	-- local bottom = elem.parn.props.direction == "HORIZONTAL" and true or elem.sibl:getKey(elem) == #elem.sibl

	local outline = elem:getLayer("outline") --[[@as FOXStencil.Border]]
	outline:setStyles({
		pos = extend_pos,
		size = extend_size,
	})
end

---@type FOXStencil.Element.Events.Press
local function press(elem, state)
	local widg = elem.widg

	widg.extend = state and 0 or 2
	widg.pressed = state
	draw(elem)

	if state then
		widg.press(widg)
	else
		widg.release(widg)
	end
end

---@type FOXStencil.Element.Events.Hover
local function hover(elem, state)
	local outline = elem:getLayer("outline") --[[@as FOXStencil.Border]]
	outline:setStyles({
		visible = state,
	})
end

---@type FOXStencil.Element.Events.Wrap
local function wrap(elem, width)
	local widg = elem.widg
	return client.getTextDimensions(widg.styles.text, width - 6) + vec(6, 4)
end


--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

local parser = require("./../../layout/core/parser") --[[@as FOXStencil.Core.Parser]]

---Sets the given styles
---@param styles FOXStencil.Button.Styles
---@return self
function obj:setStyles(styles)
	local widg = self.elem.widg
	if parser.copy(styles, widg.styles) then
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

---@param parent FOXStencil.Element|FOXStencil.Screen
---@param assets FOXStencil.Assets
return function(parent, name, assets)
	local elem = parent:newElement(name):setProps({
		size = vec(-1, -1),
	})

	---@class FOXStencil.Button
	local widg = { elem = elem }
	elem.widg = widg

	widg.press = function() end
	widg.release = function() end
	---@package
	widg.extend = 2
	widg.styles = setmetatable({}, { __index = default_styles })

	elem:newLayer("background", assets.layers.slice):setStyles({ texture = assets.themes.default.texture })
	elem:newLayer("label", assets.layers.text)
	elem:newLayer("outline", assets.layers.border):setStyles({ visible = false })

	elem.events.draw = draw
	elem.events.press = press
	elem.events.hover = hover
	elem.events.wrap = wrap

	draw(elem)

	return setmetatable(widg, obj)
end

--#ENDREGION
