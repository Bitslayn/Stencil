---@param pivot ModelPart
---@param styl FOXStencil.Styles.Part
return function(pivot, styl)
	pivot:addChild(styl.part)
end