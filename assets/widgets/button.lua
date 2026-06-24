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

---@class FOXStencil.Button.Theme
---@field normal FOXStencil.Button.Styles?
---@field enter FOXStencil.Button.Styles?
---@field leave FOXStencil.Button.Styles?
---@field press FOXStencil.Button.Styles?
---@field release FOXStencil.Button.Styles?

---@class FOXStencil.Button.Styles
---@field background FOXStencil.Slice.Styles?
---@field label FOXStencil.Text.Styles?
---@field outline FOXStencil.Border.Styles?

---@alias FOXStencil.Button.Press fun(widg: FOXStencil.Button)
---@alias FOXStencil.Button.Release fun(widg: FOXStencil.Button)

---@class FOXStencil.Button
local obj = {}
---@package
obj.__index = obj

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

-- Press and hover appearance

---@type FOXStencil.Element.Events.Press
local function press(elem, state)
	local key = state and "press" or "release"

	local widg = elem.widg --[[@as FOXStencil.Button]]
	elem:setStyles(widg.theme[key])
	widg[key](widg) -- Call user-defined function

	sounds:playSound("minecraft:block.lava.pop", elem.pointer.wrld_pos, 0.5, state and 8 or 9)
end

---@type FOXStencil.Element.Events.Hover
local function hover(elem, state)
	local widg = elem.widg --[[@as FOXStencil.Button]]
	elem:setStyles(widg.theme[state and "enter" or "leave"])
end

-- Text wrapping

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	local label = elem:getLayer("label") --[[@as FOXStencil.Text]]
	elem:setProps({ size_min = vec(client.getTextDimensions(string.gsub(label.styles.text, "%s", "\n"), 0).x + 6, 0) })
end

---@type FOXStencil.Element.Events.Wrap
local function wrap(elem, width)
	local label = elem:getLayer("label") --[[@as FOXStencil.Text]]
	return client.getTextDimensions(label.styles.text, width - 6) + vec(6, 4)
end


--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

---Sets the function to run when the button is pressed
---@param func FOXStencil.Button.Press
---@return self
function obj:onPress(func)
	if type(func) ~= "function" then error("Expected a function but found " .. type(func), 2) end
	self.press = func
	return self
end

---Sets the function to run when the button is released
---@param func FOXStencil.Button.Release
---@return self
function obj:onRelease(func)
	if type(func) ~= "function" then error("Expected a function but found " .. type(func), 2) end
	self.release = func
	return self
end

---@param styles FOXStencil.Button.Styles
---@return self
function obj:setStyles(styles)
	if select(2, self.elem:setStyles(styles)) then
		draw(self.elem)
	end

	return self
end

---@param theme FOXStencil.Button.Theme
---@return self
function obj:setTheme(theme)
	if self.elem.pressed then self.elem:setStyles(self.theme.release) end
	if self.elem.hovered then self.elem:setStyles(self.theme.leave) end

	self.theme = theme
	self.elem:setStyles(theme.normal)
	return self
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Builder ♡˚
--==============================================================================================================================

---@param parent FOXStencil.Element|FOXStencil.Screen
---@param assets FOXStencil.Assets
return function(parent, name, assets)
	local elem = parent:newElement(name):setProps({ size = vec(-1, -1) })

	---@class FOXStencil.Button
	local widg = {
		elem = elem,
		theme = assets.themes.default.button,

		press = function() end,
		release = function() end,
	}
	elem.widg = widg

	elem:newLayer("background", assets.layers.slice)
	elem:newLayer("label", assets.layers.text)
	elem:newLayer("outline", assets.layers.border)
	elem:setStyles(widg.theme.normal)

	elem.events = { press = press, hover = hover, draw = draw, wrap = wrap }
	draw(elem)

	return setmetatable(widg, obj)
end

--#ENDREGION
