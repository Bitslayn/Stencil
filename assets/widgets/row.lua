--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a row widget
---@alias FOXStencil.Row.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Row

---@class FOXStencil.Widgets
---@field row FOXStencil.Row.Generator

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Builder ♡˚
--==============================================================================================================================

---@param parent FOXStencil.Element|FOXStencil.Screen
---@param assets FOXStencil.Assets
return function(parent, name, assets)
	local elem = parent:newElement(name):setProps({ direction = "HORIZONTAL" })

	---@class FOXStencil.Row: FOXStencil.Element
	local widg = {
		elem = elem,
	}
	elem.widg = widg

	return setmetatable(widg, { __index = elem })
end

--#ENDREGION
