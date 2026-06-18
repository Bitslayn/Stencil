--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates an example widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Example.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Example

---@class FOXStencil.Widgets
---@field example FOXStencil.Example.Generator

---@class FOXStencil.Example
---@field elem FOXStencil.Element
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Example.Styles
local default_styles = {}

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

local parser = require("./../../layout/core/parser") --[[@as FOXStencil.Core.Parser]]

---Sets the given styles
---@param styles FOXStencil.Example.Styles
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
	local elem = parent:newElement(name)

	---@class FOXStencil.Button
	local widg = { elem = elem }
	elem.widg = widg

	widg.styles = setmetatable({}, { __index = default_styles })
	
	elem.events.draw = draw

	draw(elem)

	return setmetatable(widg, obj)
end

--#ENDREGION
