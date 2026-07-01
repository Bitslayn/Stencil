--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a tooltip widget
---@alias FOXStencil.Tooltip.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Tooltip

---@class FOXStencil.Widgets
---@field tooltip FOXStencil.Tooltip.Generator

---@class FOXStencil.Tooltip
local obj = {}
---@package
obj.__index = obj

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Logic ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Hover
local function hover(elem, state)
	local widg = elem.widg --[[@as FOXStencil.Tooltip]]

	widg:visible(state)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

---@param theme FOXStencil.Tooltip.Theme
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
	local elem = parent:newElement(name):setProps({ size = vec(-1, -1) })

	---@class FOXStencil.Tooltip: FOXStencil.Element
	local widg = {
		elem = elem,
		theme = assets.themes.default.tooltip,
	}
	elem.widg = widg

	function widg:__index(k)
		return obj[k] or elem[k]
	end

	---@class FOXStencil.Tooltip.Theme
	---@field normal FOXStencil.Tooltip.Styles?

	---@class FOXStencil.Tooltip.Styles
	---@field background FOXStencil.Slice.Styles?
	---@field label FOXStencil.Text.Styles?

	elem:newLayer("background", assets.layers.slice)
	elem:newLayer("label", assets.layers.text)
	elem:setStyles(widg.theme.normal)

	elem.events = { hover = hover }

	return setmetatable(widg, widg)
end

--#ENDREGION
