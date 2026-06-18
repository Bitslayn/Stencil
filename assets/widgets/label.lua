--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a label widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Label.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Label

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
	---@type string
	text = "Label",
	---@type number
	size = 9,
	---@type "CENTER"|"LEFT"|"RIGHT"
	align = "LEFT",
}

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	local widg = elem.widg

	local size = widg.styles.size / 9
	elem:setProps({
		size_min = vec(client.getTextDimensions(string.gsub(widg.styles.text, "%s", "\n"), 0).x * size, 0),
	})

	local align = widg.styles.align
	local pan = 0

	if align == "RIGHT" then
		pan = 1
	elseif align == "CENTER" then
		pan = 0.5
	end

	local label = elem:getLayer("label") --[[@as FOXStencil.Text]]
	label:setStyles({
		pos = vec(elem.state.size.x * pan, 0),
		size = widg.styles.size,
		width = elem.state.size.x,

		text = widg.styles.text,
		align = align,
	})
end

---@type FOXStencil.Element.Events.Wrap
local function wrap(elem, width)
	local widg = elem.widg
	local size = widg.styles.size / 9
	return client.getTextDimensions(widg.styles.text, width / size) * size
end


--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

local parser = require("./../../layout/core/parser") --[[@as FOXStencil.Core.Parser]]

---Sets the given styles
---@param styles FOXStencil.Label.Styles
---@return self
function obj:setStyles(styles)
	local widg = self.elem.widg
	if parser.copy(styles, widg.styles) then
		draw(self.elem)
	end

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

	---@class FOXStencil.Label
	local widg = { elem = elem }
	elem.widg = widg

	widg.styles = setmetatable({}, { __index = default_styles })

	elem:newLayer("label", assets.layers.text)

	elem.events.draw = draw
	elem.events.wrap = wrap

	draw(elem)

	return setmetatable(widg, obj)
end

--#ENDREGION
