--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---@class FOXStencil.Core.Interact
local lib = {}

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Press ♡˚
--==============================================================================================================================

local was_pressed = false

---@type boolean
local mouse_press
function events.mouse_press(_, state)
	mouse_press = state ~= 0 or false
end

---Returns if the host is pressing the screen
---@return boolean state
---@return boolean change
local function get_screen_press()
	local mouse_visible = host:isChatOpen() or action_wheel:isEnabled() or host:isCursorUnlocked()

	local is_pressed = mouse_visible and mouse_press
	if was_pressed == is_pressed then return is_pressed, false end

	was_pressed = is_pressed

	return is_pressed, true
end

---Returns if the viewer started swinging or using an item
---@return boolean state
---@return boolean change
local function get_world_press()
	local viewer = client.getViewer()

	local swing_time = viewer:getSwingTime()
	local is_pressed = 0 < swing_time and swing_time < 3 or viewer:isUsingItem()
	if was_pressed == is_pressed then return is_pressed, false end

	was_pressed = is_pressed

	return is_pressed, true
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Interact ♡˚
--==============================================================================================================================

---@param elem FOXStencil.Element?
---@param root FOXStencil.Screen
---@param state boolean
---@return boolean
local function do_press(elem, root, state)
	-- Release last element

	if root.pressed and not state then
		root.pressed.events.press(root.pressed, false)
		root.pressed.pressed = false
		root.pressed = nil
	end

	-- Press current element

	if elem and state and elem.events.press and not elem.events.press(elem, true) then
		elem.pressed = true
		root.pressed = elem
		return true
	end

	return false
end

---@param elem FOXStencil.Element?
---@param root FOXStencil.Screen
---@param state boolean
---@return boolean
local function do_hover(elem, root, state)
	local hovered = root.hovered

	-- Enter current element

	if elem and elem.events.hover and not elem.events.hover(elem, true) then
		elem.hovered = true
		root.hovered = elem
		state = true
	end

	-- Leave last element

	if hovered and state and elem ~= hovered then
		hovered.events.hover(hovered, false)
		if hovered == root.hovered then
			hovered.hovered = false
			root.hovered = nil
		end
	end

	return state
end

---Recursively gets the tree of elements being hovered over
---@param list FOXStencil.Element[]
---@param elem FOXStencil.Element
---@param elem_pos Vector2
---@param root_pos Vector2
---@param wrld_pos Vector3
---@return boolean
local function get_hovered(list, elem, elem_pos, root_pos, wrld_pos)
	local pos = elem.state.pos
	local size = elem.state.size

	elem.pointer.elem_pos = elem_pos - pos
	elem.pointer.move_pos = root_pos - elem.pointer.root_pos
	elem.pointer.root_pos = root_pos:copy()
	elem.pointer.wrld_pos = wrld_pos:copy()

	if not (pos <= elem_pos and elem_pos <= pos + size and elem.props.visible) then return false end

	list[#list + 1] = elem
	elem_pos = elem_pos - pos


	for i = #elem.chld, 1, -1 do
		if get_hovered(list, elem.chld[i], elem_pos, root_pos, wrld_pos) then break end
	end

	return true
end

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@param press_state boolean
---@param press_changed boolean
---@param elem_pos Vector2
---@param root_pos Vector2
---@param wrld_pos Vector3
function lib.relative_hover(elem, press_state, press_changed, elem_pos, root_pos, wrld_pos)
	local root = elem.root

	root.pointer.elem_pos = elem_pos:copy()
	root.pointer.move_pos = root_pos - root.pointer.root_pos
	root.pointer.root_pos = root_pos:copy()
	root.pointer.wrld_pos = wrld_pos:copy()

	---@type FOXStencil.Element[]
	local list = {}

	get_hovered(list, elem, elem_pos, root_pos, wrld_pos)

	if root.pressed and root.pressed.events.drag then
		root.pressed.events.drag(root.pressed, root.pressed.pointer.move_pos)
	end

	for i = 1, #list do
		if do_hover(list[i], root, i == #list) then break end
	end

	if press_changed then
		for i = 1, #list do
			if do_press(list[i], root, press_state) then break end
		end
	end

	return #list > 0
end

---@param root FOXStencil.Screen
function lib.reset(root)
	do_hover(nil, root, true)
	do_press(nil, root, was_pressed)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Hover ♡˚
--==============================================================================================================================

-- TODO Why is each child of a screen recalculating the root hover position?

-- Written by 4P5 ★

local EPSILON = 2.2204460492503131e-16
local dot = vectors.vec3().dot

---@param ray_pos Vector3
---@param ray_dir Vector3
---@param plane_pos Vector3
---@param plane_normal Vector3
---@return Vector3? intersection_point
local function intersect_plane(ray_pos, ray_dir, plane_pos, plane_normal)
	local denom = dot(plane_normal, ray_dir)
	if -denom < EPSILON then return end
	local d = plane_pos - ray_pos
	local t = dot(d, plane_normal) / denom
	if t < EPSILON then return end
	return ray_pos + ray_dir * t
end

------------------------------------------------------------------------------------------------
--#REGION ˚♡ Hover > Screen ♡˚
------------------------------------------------------------------------------------------------

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@return boolean
function lib.screen_hover(elem)
	local press_state, press_changed = get_screen_press()

	local root_pos = client.getMousePos() / client.getGuiScale()
	return lib.relative_hover(elem, press_state, press_changed, root_pos, root_pos, client.getCameraPos())
end

--#ENDREGION -----------------------------------------------------------------------------------
--#REGION ˚♡ Hover > World ♡˚
------------------------------------------------------------------------------------------------

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@return boolean
function lib.world_hover(elem)
	local mat = elem.root.part:partToWorldMatrix()

	local press_state, press_changed = get_world_press()

	local hit = intersect_plane(client.getCameraPos(), client.getCameraDir(), mat:apply(), mat:applyDir(0, 0, -1))
	if not hit then return false end

	local root_pos = mat:inverted():apply(hit).xy * vec(1, -1)
	return lib.relative_hover(elem, press_state, press_changed, root_pos, root_pos, hit)
end

--#ENDREGION -----------------------------------------------------------------------------------
--#REGION ˚♡ Hover > Skull ♡˚
------------------------------------------------------------------------------------------------

local face = {
	north = 0,
	east = 4,
	south = 8,
	west = 12,
}

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@param block BlockState
---@return boolean
function lib.skull_hover(elem, block)
	local pos = block.id:find("wall") and vec(0, -0.25, 0.25) or vec(0, -0.5, 0)
	local rot = tonumber(block.properties.rotation) or face[block.properties.facing]

	local mat = matrices.translate4(block:getPos() + 0.5)
		* matrices.rotation4(0, rot and rot * -22.5 or 0, 0)
		* matrices.translate4(pos)
		* matrices.scale4(1 / 16)
		* elem.root.part:getParent():getPositionMatrixRaw()

	local press_state, press_changed = get_world_press()

	local hit = intersect_plane(client.getCameraPos(), client.getCameraDir(), mat:apply(), mat:applyDir(0, 0, -1))
	if not hit then return false end

	local root_pos = -mat:inverted():apply(hit).xy
	return lib.relative_hover(elem, press_state, press_changed, root_pos, root_pos, hit)
end

return lib

--#ENDREGION

--#ENDREGION
