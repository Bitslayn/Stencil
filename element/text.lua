---@param pivot ModelPart
---@param styl FOXStencil.Styles.Text
return function(pivot, styl)
	pivot:newText("task")
		:text(styl.text)
		:outline(not not styl.outline)
		:outlineColor(styl.outline)
		:light(15)
end
