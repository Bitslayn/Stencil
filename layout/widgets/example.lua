--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---Generates an example widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Example.Generator fun(parent: FOXStencil.Element, name: string, layers: FOXStencil.Layers, widgets: FOXStencil.Widgets): FOXStencil.Example

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
--#REGION ˚♡ Builder ♡˚
--==============================================================================================================================

local copy = require("./../core/parser").copy

---Sets the given styles
---@param styles FOXStencil.Example.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.elem.widg.styles) then
		draw(self.elem)
	end

	return self
end

---@param parent FOXStencil.Element
---@param layers FOXStencil.Layers
---@param widgets FOXStencil.Widgets
return function(parent, name, layers, widgets)
	local elem = parent:newElement(name)

	---@class FOXStencil.Example
	local self = { elem = elem }
	elem.widg.styles = setmetatable({}, { __index = default_styles })
	
	elem.events.draw = draw

	draw(elem)

	return setmetatable(self, obj)
end

--#ENDREGION
