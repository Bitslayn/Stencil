---@param pivot ModelPart
---@param styl FOXStencil.Styles.Text
return function(pivot, styl)
	pivot:newText("task")
		:text(styl.text)
		:width(styl.size.x)
		:outline(not not styl.outline)
		:outlineColor(styl.outline)
		:light(15)
end
