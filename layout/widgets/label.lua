--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---Generates a label widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Label.Generator fun(parent: FOXStencil.Element, name: string, layers: FOXStencil.Layers, widgets: FOXStencil.Widgets): FOXStencil.Label

---@class FOXStencil.Widgets
---@field label FOXStencil.Label.Generator

---@alias FOXStencil.Label.Press fun(widg: FOXStencil.Label)
---@alias FOXStencil.Label.Release fun(widg: FOXStencil.Label)

---@class FOXStencil.Label
---@field elem FOXStencil.Element
---@field press FOXStencil.Label.Press
---@field release FOXStencil.Label.Release
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Label.Styles
local default_styles = {
	text = "Label",
	size = 9,
}

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	local size = elem.widg.styles.size / 9
	elem:setProps({
		size_min = vec(client.getTextDimensions(string.gsub(elem.widg.styles.text, "%s", "\n"), 0).x * size, 0),
	})

	---@type FOXStencil.Text
	local label = elem:getLayer("label")
	label:setStyles({
		text = elem.widg.styles.text,
		width = elem.state.size.x,
		size = elem.widg.styles.size,
	})
end

---@type FOXStencil.Element.Events.Wrap
local function wrap(elem, width)
	local size = elem.widg.styles.size / 9
	return client.getTextDimensions(elem.widg.styles.text, width / size) * size
end


--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

local copy = require("./../core/parser").copy

---Sets the given styles
---@param styles FOXStencil.Label.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.elem.widg.styles) then
		draw(self.elem)
	end

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

	---@class FOXStencil.Label
	local widg = { elem = elem }
	elem.widg = widg

	widg.styles = setmetatable({}, { __index = default_styles })

	elem:newLayer("label", layers.text)

	elem.events.draw = draw
	elem.events.wrap = wrap

	draw(elem)

	return setmetatable(widg, obj)
end

--#ENDREGION
