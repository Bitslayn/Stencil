---@class FOXStencil.Core.Interact
local lib = {}

-- TODO Clean up this mess part 2

---@param root FOXStencil.Screen
---@param elem FOXStencil.Element?
---@param click boolean
---@param rel_pos Vector2
---@param true_pos Vector2
---@param sound_pos Vector3
local function interact(root, elem, click, rel_pos, true_pos, sound_pos)
	-- Unhover last hovered element

	if root.clicked and not click then
		local props = root.clicked.props
		
		if props.click then
			props.click(rel_pos, true_pos, sound_pos, false)
		end

		root.clicked = nil
	end

	if root.hovered and root.hovered ~= elem then
		local props = root.hovered.props
		
		if props.hover then
			props.hover(rel_pos, true_pos, sound_pos, false, true)
		end

		root.hovered = nil
	end

	if not elem then return end

	local props = elem.props

	-- Hover currently hovered element

	local changed = root.hovered ~= elem
	root.hovered = elem
	
	if props.hover then
		props.hover(rel_pos, true_pos, sound_pos, true, changed)
	end

	elem.state.hover_pos = rel_pos

	-- Click through to clickable element

	if not root.clicked and click then
		while elem.parn and not props.click do
			rel_pos = rel_pos + elem.state.pos
			elem = elem.parn --[[@as FOXStencil.Element]]
			props = elem.props
		end
		
		if props.click then
			props.click(rel_pos, true_pos, sound_pos, true)
		end
		root.clicked = elem

		local time = world.getTime()
		if root.click_time == time then return end

		root.click_time = time
	end

	elem.state.hover_pos = rel_pos
end

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@param click boolean
---@param rel_pos Vector2
---@param true_pos Vector2
---@param sound_pos Vector3
---@return FOXStencil.Element?
function lib.relative_hover(elem, click, rel_pos, true_pos, sound_pos)
	if not rel_pos then return end
	local root = elem.root

	-- TODO Fix bug with this that causes hovering to not behave properly
	-- Focus elements that have been clicked, up until they are no longer clicked

	local clicked = elem.root.clicked
	if clicked then
		interact(root, clicked, click, clicked.state.hover_pos, true_pos, sound_pos)
		return clicked
	end

	-- TODO Fix clicking outside an element then moving cursor into element triggering a click for that element

	local state = elem.state
	local bound_pos = state.pos
	local bound_size = state.size
	if not (bound_pos <= rel_pos and rel_pos <= bound_pos + bound_size and elem.state.visible) then return end

	rel_pos = rel_pos - state.pos

	-- Find hovered child element

	for i = #elem.chld, 1, -1 do
		local res = lib.relative_hover(elem.chld[i], click, rel_pos, true_pos, sound_pos)
		if res then return res end
	end

	interact(root, elem, click, rel_pos, true_pos, sound_pos)

	return elem
end

---@param root FOXStencil.Screen
function lib.reset(root)
	interact(root, nil, false, vec(0, 0), vec(0, 0), vec(0, 0, 0))
end

---@type boolean
local mouse_press
function events.mouse_press(button, state)
	if button ~= 0 then return end
	local mouse_visible = host:isChatOpen() or action_wheel:isEnabled() or host:isCursorUnlocked()
	mouse_press = mouse_visible and state ~= 0 or false
end

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@return FOXStencil.Element?
function lib.screen_hover(elem)
	if not (host:isChatOpen() or action_wheel:isEnabled() or host:isCursorUnlocked()) then return end
	local true_pos = client.getMousePos() / client.getGuiScale()
	return lib.relative_hover(elem, mouse_press, true_pos, true_pos, client.getCameraPos())
end

local EPSILON = 2.2204460492503131e-16
local dot = vectors.vec3().dot

---@param ray_pos Vector3
---@param ray_dir Vector3
---@param plane_pos Vector3
---@param plane_normal Vector3
---@return Vector3? intersection_point
local function intersectPlane(ray_pos, ray_dir, plane_pos, plane_normal)
	local denom = dot(plane_normal, ray_dir)
	if -denom < EPSILON then return end
	local d = plane_pos - ray_pos
	local t = dot(d, plane_normal) / denom
	if t < EPSILON then return end
	return ray_pos + ray_dir * t
end

---@param hit_pos Vector3
---@param plane_mat Matrix4
---@return Vector3
local function worldToLocal(hit_pos, plane_mat)
	local pos_mat = matrices.translate4(plane_mat:apply())
	local rot_mat = matrices.rotation4(0, 180, 0) * (pos_mat:inverted() * plane_mat):inverted()

	return (rot_mat * matrices.translate4(hit_pos - plane_mat:apply())):apply()
end

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@return FOXStencil.Element?
function lib.world_hover(elem)
	local mat = elem.root.part:partToWorldMatrix()

	local viewer = client.getViewer()
	local ray_pos = viewer:getPos(client.getFrameTime())
		:add(0, viewer:getEyeHeight(), 0)
		:add(viewer:getVariable("eyePos"))
	local ray_dir = viewer:getLookDir()

	local hit = intersectPlane(ray_pos, ray_dir, mat:apply(), mat:applyDir(0, 0, -1))
	if not hit then return end

	local swing = viewer:getSwingTime()
	local click = 0 < swing and swing < 3 or viewer:isUsingItem()

	local true_pos = worldToLocal(hit, mat).xy * vec(1, -1)
	return lib.relative_hover(elem, click, true_pos, true_pos, hit)
end

local face = {
	north = 0,
	east = 4,
	south = 8,
	west = 12,
}

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@param block BlockState
---@return FOXStencil.Element?
function lib.skull_hover(elem, block)
	local pos = block.id:find("wall") and vec(0, -0.25, 0.25) or vec(0, -0.5, 0)
	local rot = tonumber(block.properties.rotation) or face[block.properties.facing]

	local mat = matrices.translate4(block:getPos() + 0.5)
		* matrices.rotation4(0, rot and rot * -22.5 or 0, 0)
		* matrices.translate4(pos)
		* matrices.scale4(1 / 16)
		* elem.root.part:getParent():getPositionMatrixRaw()

	local viewer = client.getViewer()
	local ray_pos = viewer:getPos(client.getFrameTime())
		:add(0, viewer:getEyeHeight(), 0)
		:add(viewer:getVariable("eyePos"))
	local ray_dir = viewer:getLookDir()

	local hit = intersectPlane(ray_pos, ray_dir, mat:apply(), mat:applyDir(0, 0, -1))
	if not hit then return end

	local swing = viewer:getSwingTime()
	local click = 0 < swing and swing < 3 or viewer:isUsingItem()

	local true_pos = worldToLocal(hit, mat).xy * vec(1, -1)
	return lib.relative_hover(elem, click, true_pos, true_pos, hit)
end

return lib
