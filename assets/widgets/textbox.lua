--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a textbox widget
---@alias FOXStencil.Textbox.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Textbox

---@class FOXStencil.Widgets
---@field textbox FOXStencil.Textbox.Generator

---@class FOXStencil.Textbox
local obj = {}
---@package
obj.__index = obj

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Press
local function press(elem, state)

end

---@type FOXStencil.Element.Events.Hover
local function hover(elem, state)
	local widg = elem.widg --[[@as FOXStencil.Button]]
	elem:setStyles(widg.theme[state and "enter" or "leave"])
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

---@param theme FOXStencil.Textbox.Theme
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

local str = require("./../../layout/types/string") --[[@as FOXStencil.String]]

---@param parent FOXStencil.Element|FOXStencil.Screen
---@param assets FOXStencil.Assets
return function(parent, name, assets)
	local elem = parent:newElement(name):setProps({ size = vec(100, 13) })

	---@class FOXStencil.Textbox
	local widg = {
		elem = elem,
		text = str.of(""), -- αβψδεφγ
		theme = assets.themes.default.textbox,
	}
	elem.widg = widg

	function widg:__index(k)
		return obj[k] or elem[k]
	end

	---@class FOXStencil.Textbox.Theme
	---@field normal FOXStencil.Textbox.Styles?
	---@field enter FOXStencil.Textbox.Styles?
	---@field leave FOXStencil.Textbox.Styles?
	---@field press FOXStencil.Textbox.Styles?
	---@field release FOXStencil.Textbox.Styles?

	---@class FOXStencil.Textbox.Styles
	---@field background FOXStencil.Slice.Styles?
	---@field label FOXStencil.Text.Styles?
	---@field outline FOXStencil.Border.Styles?
	---@field caret FOXStencil.Sprite.Styles?

	elem:newLayer("background", assets.layers.slice)
	elem:newLayer("label", assets.layers.text)
	elem:newLayer("outline", assets.layers.border)
	elem:newLayer("caret", assets.layers.sprite)
	elem:setStyles(widg.theme.normal)

	elem.events = { press = press, hover = hover }

	return setmetatable(widg, widg)
end

--#ENDREGION
