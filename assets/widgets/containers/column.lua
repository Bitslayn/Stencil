--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a row widget
---@alias FOXStencil.Column.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Row

---@class FOXStencil.Widgets
---@field column FOXStencil.Column.Generator

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Builder ♡˚
--==============================================================================================================================

---@param parent FOXStencil.Element|FOXStencil.Screen
---@param assets FOXStencil.Assets
return function(parent, name, assets)
	local elem = parent:newElement(name):setProps({ size = vec(0, -1), align = vec(0.5, 0), gap = 2, direction = "VERTICAL" })

	---@class FOXStencil.Row: FOXStencil.Element
	local widg = {
		elem = elem,
	}
	elem.widg = widg

	return setmetatable(widg, { __index = elem })
end

--#ENDREGION
