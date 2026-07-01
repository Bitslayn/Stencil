--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a label widget
---@alias FOXStencil.Label.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Label

---@class FOXStencil.Widgets
---@field label FOXStencil.Label.Generator

---@class FOXStencil.Label
local obj = {}
---@package
obj.__index = obj

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Logic ♡˚
--==============================================================================================================================

-- Text wrapping

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	local label = elem:getLayer("label") --[[@as FOXStencil.Text]]
	local size = label.styles.size / 9
	elem:setProps({ size_min = vec(client.getTextDimensions(string.gsub(label.styles.text, "%s", "\n"), 0).x * size, 0) })
end

---@type FOXStencil.Element.Events.Wrap
local function wrap(elem, width)
	local label = elem:getLayer("label") --[[@as FOXStencil.Text]]
	local size = label.styles.size / 9
	return client.getTextDimensions(label.styles.text, width / size) * size
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

---@param styles FOXStencil.Label.Styles
---@return self
function obj:setStyles(styles)
	if select(2, self.elem:setStyles(styles)) then
		draw(self.elem)
	end

	return self
end

---@param theme FOXStencil.Label.Theme
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

	---@class FOXStencil.Label: FOXStencil.Element
	local widg = {
		elem = elem,
		theme = assets.themes.default.label,
	}
	elem.widg = widg

	function widg:__index(k)
		return obj[k] or elem[k]
	end

	---@class FOXStencil.Label.Theme
	---@field normal FOXStencil.Label.Styles?

	---@class FOXStencil.Label.Styles
	---@field label FOXStencil.Text.Styles?

	elem:newLayer("label", assets.layers.text)
	elem:setStyles(widg.theme.normal)

	elem.events = { draw = draw, wrap = wrap }
	draw(elem)

	return setmetatable(widg, widg)
end

--#ENDREGION
