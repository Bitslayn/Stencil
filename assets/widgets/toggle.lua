--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

-- WIP!!!

---Generates a toggle widget
---@alias FOXStencil.Toggle.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Toggle

---@class FOXStencil.Widgets
---@field toggle FOXStencil.Toggle.Generator

---@class FOXStencil.Toggle
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

	local widg = elem.widg --[[@as FOXStencil.Toggle]]
	elem:setStyles(widg.theme[key])
	if widg[key] then widg[key](widg) end -- Call user-defined function

	sounds:playSound("minecraft:block.lava.pop", elem.pointer.wrld_pos, 0.5, state and 8 or 9)
end

---@type FOXStencil.Element.Events.Hover
local function hover(elem, state)
	local widg = elem.widg --[[@as FOXStencil.Toggle]]
	elem:setStyles(widg.theme[state and "enter" or "leave"])
end

-- Text wrapping

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	local label = elem:getLayer("label") --[[@as FOXStencil.Text]]
	local size = label.styles.size / 9
	elem:setProps({ size_min = vec(client.getTextDimensions(string.gsub(label.styles.text, "%s", "\n"), 0).x * size + 6, 0) })
end

---@type FOXStencil.Element.Events.Wrap
local function wrap(elem, width)
	local label = elem:getLayer("label") --[[@as FOXStencil.Text]]
	local size = label.styles.size / 9
	return client.getTextDimensions(label.styles.text, (width - 6) / size) * size + vec(6, 6)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

---Sets the function to run when the toggle is pressed
---@param func FOXStencil.Toggle.Press
---@return self
function obj:onPress(func)
	if func ~= nil and type(func) ~= "function" then error("Expected a function but found " .. type(func), 2) end
	self.press = func
	return self
end

---Sets the function to run when the toggle is released
---@param func FOXStencil.Toggle.Release
---@return self
function obj:onRelease(func)
	if func ~= nil and type(func) ~= "function" then error("Expected a function but found " .. type(func), 2) end
	self.release = func
	return self
end

---@param styles FOXStencil.Toggle.Styles
---@return self
function obj:setStyles(styles)
	if select(2, self.elem:setStyles(styles)) then
		draw(self.elem)
	end

	return self
end

---@param theme FOXStencil.Toggle.Theme
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

	---@alias FOXStencil.Toggle.Press fun(widg: FOXStencil.Toggle)
	---@alias FOXStencil.Toggle.Release fun(widg: FOXStencil.Toggle)

	---@class FOXStencil.Toggle: FOXStencil.Element
	---@field press FOXStencil.Toggle.Press
	---@field release FOXStencil.Toggle.Release
	local widg = {
		elem = elem,
		theme = assets.themes.default.toggle,
	}
	elem.widg = widg

	function widg:__index(k)
		return obj[k] or elem[k]
	end

	---@class FOXStencil.Toggle.Theme
	---@field normal FOXStencil.Toggle.Styles?
	---@field enter FOXStencil.Toggle.Styles?
	---@field leave FOXStencil.Toggle.Styles?
	---@field press FOXStencil.Toggle.Styles?
	---@field release FOXStencil.Toggle.Styles?

	---@class FOXStencil.Toggle.Styles
	---@field background FOXStencil.Slice.Styles?
	---@field label FOXStencil.Text.Styles?
	---@field outline FOXStencil.Border.Styles?

	elem:newLayer("background", assets.layers.slice)
	elem:newLayer("label", assets.layers.text)
	elem:newLayer("outline", assets.layers.border)
	elem:setStyles(widg.theme.normal)

	elem.events = { press = press, hover = hover, draw = draw, wrap = wrap }
	draw(elem)

	return setmetatable(widg, widg)
end

--#ENDREGION
