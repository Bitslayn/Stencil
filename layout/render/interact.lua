---@class FOXStencil.Render.Interact
local lib = {}

---@param root FOXStencil.Layout
---@param elem FOXStencil.Element?
---@param click boolean
---@param rel_pos Vector2
---@param true_pos Vector2
local function interact(root, elem, click, rel_pos, true_pos)
	-- Unhover last hovered element

	if root.clicked and not click then
		local props = root.clicked:getProps()

		props.click(root.clicked, rel_pos, true_pos, false)
		root.clicked.group = bit32.band(root.clicked.group, 1)
		root.clicked:draw(true)

		root.clicked = nil
	end

	if root.hovered and root.hovered ~= elem then
		local props = root.hovered:getProps()
		if props.hover then
			props.hover(root.hovered, rel_pos, true_pos, false, true)
			root.hovered.group = bit32.band(root.hovered.group, 2)
			root.hovered:draw(true)

			root.hovered = nil
		end
	end

	if not elem then return end

	local props = elem:getProps()

	-- Hover currently hovered element

	if not root.clicked and props.click and click then
		root.clicked = elem

		local time = world.getTime()
		if root.click_time == time then return end

		props.click(elem, rel_pos, true_pos, true)
		elem.group = bit32.bor(elem.group, 2)
		elem:draw(true)

		root.click_time = time
	end

	if props.hover then
		local changed = root.hovered ~= elem
		root.hovered = elem

		props.hover(elem, rel_pos, true_pos, true, changed)
		if changed then
			elem.group = bit32.bor(elem.group, 1)
			elem:draw(true)
		end
	end

	elem.state.hover_pos = rel_pos
end

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@param click boolean
---@param rel_pos Vector2
---@param true_pos Vector2
---@return FOXStencil.Element?
function lib.relative_hover(elem, click, rel_pos, true_pos)
	if not rel_pos then return end
	local root = elem.root

	-- Focus elements that have been clicked, up until they are no longer clicked

	local clicked = elem.root.clicked
	if clicked then
		interact(root, clicked, click, clicked.state.hover_pos, true_pos)
		return clicked
	end

	-- TODO Fix clicking outside an element then moving cursor into element triggering a click for that element

	local props = elem:getProps()
	local state = elem.state

	-- TODO Precalculate these values from the layout class

	local extend = props.tex_extend
	local tmp_pos = state.pos - extend.wx
	local tmp_size = state.size + extend.wx + extend.yz
	if not (tmp_pos <= rel_pos and rel_pos <= tmp_pos + tmp_size and elem.state.visible) then return end

	rel_pos = rel_pos - state.pos

	-- Find hovered child element

	for i = #elem.chld, 1, -1 do
		local res = lib.relative_hover(elem.chld[i], click, rel_pos, true_pos)
		if res then
			elem.hover_index = i
			return res
		end
	end

	interact(root, elem, click, rel_pos, true_pos)

	return elem
end

---@param root FOXStencil.Layout
function lib.reset(root)
	interact(root, nil, false, vec(0, 0), vec(0, 0))
end

local mouse_press
function events.mouse_press(button, state)
	if not (host:isChatOpen() or action_wheel:isEnabled() or host:isCursorUnlocked()) then return end
	if 1 < button then return end
	mouse_press = state ~= 0
	-- mouse_press = state ~= 0 and button % 2
end

-- TODO Fix bug where holding down click and hiding mouse cursor will cause the click to still be held

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@return FOXStencil.Element?
function lib.screen_hover(elem)
	if not (host:isChatOpen() or action_wheel:isEnabled() or host:isCursorUnlocked()) then return end
	local true_pos = client.getMousePos() / client.getGuiScale()
	return lib.relative_hover(elem, mouse_press, true_pos, true_pos)
end

local EPSILON = 2.2204460492503131e-16
local abs = math.abs
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

	local hit = intersectPlane(
		client.getCameraPos(),
		client.getCameraDir(),
		mat:apply(),
		mat:applyDir(0, 0, -1)
	)
	if not hit then return end

	local viewer = client.getViewer()
	local swing = viewer:getSwingTime()
	local click = 0 < swing and swing < 3 or viewer:isUsingItem()

	local true_pos = worldToLocal(hit, mat).xy * vec(1, -1)
	return lib.relative_hover(elem, click, true_pos, true_pos)
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

	local hit = intersectPlane(
		client.getCameraPos(),
		client.getCameraDir(),
		mat:apply(),
		mat:applyDir(0, 0, -1)
	)
	if not hit then return end

	local viewer = client.getViewer()
	local swing = viewer:getSwingTime()
	local click = 0 < swing and swing < 3 or viewer:isUsingItem()

	local true_pos = worldToLocal(hit, mat).xy * vec(1, -1)
	return lib.relative_hover(elem, click, true_pos, true_pos)
end

return lib
