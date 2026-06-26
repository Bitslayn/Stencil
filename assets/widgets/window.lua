--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a window widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Window.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Window

---@class FOXStencil.Widgets
---@field window FOXStencil.Window.Generator

---@class FOXStencil.Window
local obj = {}
---@package
obj.__index = obj

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Press
local function press(elem)
	return elem.pointer.elem_pos.y > 13
end

---@type FOXStencil.Element.Events.Drag
local function drag(elem, move)
	elem:setProps({ pos = elem.props.pos + move })
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

function obj:newElement(...)
	return self.elem:newElement(...)
end

function obj:newWidget(...)
	return self.elem:newWidget(...)
end

---@param styles FOXStencil.Window.Styles
---@return self
function obj:setStyles(styles)
	self.elem:setStyles(styles)
	return self
end

---@param theme FOXStencil.Window.Theme
---@return self
function obj:setTheme(theme)
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
	local elem = parent:newElement(name):setProps({ padding = vec(15, 3, 3, 3) })

	---@class FOXStencil.Window
	local widg = {
		elem = elem,
		theme = assets.themes.default.window,
	}
	elem.widg = widg

	---@class FOXStencil.Window.Theme
	---@field normal FOXStencil.Window.Styles?

	---@class FOXStencil.Window.Styles
	---@field background FOXStencil.Slice.Styles?
	---@field toolbar FOXStencil.Slice.Styles?
	---@field title FOXStencil.Text.Styles?
	---@field icon FOXStencil.Text.Styles?

	elem:newLayer("background", assets.layers.slice)
	elem:newLayer("toolbar", assets.layers.slice)
	elem:newLayer("title", assets.layers.text)
	elem:newLayer("icon", assets.layers.text)
	elem:setStyles(widg.theme.normal)

	elem.events = { press = press, drag = drag }

	return setmetatable(widg, obj)
end

--#ENDREGION
