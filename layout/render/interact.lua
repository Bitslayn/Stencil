---@class FOXStencil.Render.Interact
local lib = {}

---@param root FOXStencil.Layout
---@param click boolean
---@param elem FOXStencil.Element?
---@param pos Vector2?
local function interact(root, click, elem, pos)
	-- Unhover last hovered element

	if root.hovered and root.hovered ~= elem then
		local props = root.hovered:getProps()
		local state = root.hovered.state
		if props.hover then
			props.hover(root.hovered, state.hover_pos, false, true)
			root.hovered.group = bit32.band(root.hovered.group, 2)
			root.hovered:draw(true)

			root.hovered = nil
		end
	end

	if root.clicked and not click then
		local props = root.clicked:getProps()
		local state = root.clicked.state

		props.click(root.clicked, state.hover_pos, false)
		root.clicked.group = bit32.band(root.clicked.group, 1)
		root.clicked:draw(true)

		root.clicked = nil
	end

	if not (elem and pos) then return end

	local props = elem:getProps()

	-- Hover currently hovered element

	if props.hover then
		local changed = root.hovered ~= elem
		root.hovered = elem
		
		props.hover(elem, pos, true, changed)
		if changed then
			elem.group = bit32.bor(elem.group, 1)
			elem:draw(true)
		end
	end

	if not root.clicked and props.click and click then
		root.clicked = elem

		local time = world.getTime()
		if root.click_time == time then return end

		props.click(elem, pos, true)
		elem.group = bit32.bor(elem.group, 2)
		elem:draw(true)

		root.click_time = time
	end

	props.hover_pos = pos
end

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@param click boolean
---@param pos Vector2?
---@return FOXStencil.Element?
function lib.relative_hover(elem, click, pos)
	local root = elem.root
	local props = elem:getProps()
	local state = elem.state

	if not pos then
		return interact(root, click)
	end

	local extend = props.tex_extend
	local tmp_pos = state.pos - extend.wx
	local tmp_size = state.size + extend.wx + extend.yz
	if not (tmp_pos <= pos and pos <= tmp_pos + tmp_size) then
		if not elem.parn then
			interact(root, click)
		end
		return
	end

	pos = pos - state.pos

	-- Find hovered child element

	for i = #elem.chld, 1, -1 do
		local res = lib.relative_hover(elem.chld[i], click, pos)
		if res then
			elem.hover_index = i
			return res
		end
	end

	interact(root, click, elem, pos)

	return elem
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
	return lib.relative_hover(elem, mouse_press, client.getMousePos() / client.getGuiScale())
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
	local mat = elem.part:partToWorldMatrix()

	local pos_mat = matrices.translate4(mat:apply())
	local rot_mat = matrices.rotation4(0, 180, 0) * (pos_mat:inverted() * mat):inverted()

	local hit = intersectPlane(
		client.getCameraPos(),
		client.getCameraDir(),
		mat:apply(),
		mat:applyDir(0, 0, -1)
	)

	local viewer = client.getViewer()
	local swing = viewer:getSwingTime()
	local click = 0 < swing and swing < 3 or viewer:isUsingItem()

	return lib.relative_hover(elem, click, hit and worldToLocal(hit, mat).xy * vec(1, -1))
end

return lib
