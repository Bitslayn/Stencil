---@param pivot ModelPart
---@param styl FOXStencil.Styles.Task
return function(pivot, styl)
	local rot = styl.task:getRot()
		+ vec(30, -135, 0)

	---@type Vector3
	local size
	if type(styl.task) == "EntityTask" then
		local entity = styl.task --[[@as EntityTask]]:asEntity()
		size = entity and entity:getBoundingBox()._y_ --[[@as Vector3]] * -8 or vectors.vec3()
	else
		size = vec(-8, -8, -8)
	end

	local mat = matrices.mat4()
		* matrices.translate4(0, 0, -100)
		* matrices.xRotation4(-rot.x)
		* matrices.yRotation4(rot.y)
		* matrices.zRotation4(rot.z)
		* matrices.translate4(size)

	pivot:newPart("task")
		:matrix(mat)
		:addTask(styl.task)
end
