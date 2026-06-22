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

---Returns if the host is clicking the screen
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
---@param viewer Player
---@return boolean state
---@return boolean change
local function get_world_press(viewer)
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
---@return boolean
local function hover(elem, root)
	-- Leave last element

	local hovered = root.hovered
	if hovered and hovered ~= elem then
		hovered.events.hover(hovered, false, nil)
	end

	-- Enter current element

	if not elem then return false end

	if elem.events.hover and not elem.events.hover(elem, true, nil) then
		elem.root.hovered = elem
		return true
	end

	return false
end

---@param elem FOXStencil.Element?
---@param root FOXStencil.Screen
---@param state boolean
---@return boolean
local function press(elem, root, state)
	-- Release last element

	local pressed = root.pressed
	if pressed and not state then
		pressed.events.press(pressed, false, nil)
	end
	
	-- Press current element

	if not elem then return false end

	if state and elem.events.press and not elem.events.press(elem, true, nil) then
		elem.root.pressed = elem
		return true
	end

	return false
end

---Recursively gets the tree of elements being hovered over
---@param elem FOXStencil.Element
---@param rel_pos Vector2
---@param list FOXStencil.Element[]
---@return boolean
local function get_hovered_list(elem, rel_pos, list)
	local pos = elem.state.pos
	local size = elem.state.size

	if not (pos <= rel_pos and rel_pos <= pos + size and elem.props.visible) then return false end

	list[#list + 1] = elem
	rel_pos = rel_pos - pos

	for i = #elem.chld, 1, -1 do
		local chld = elem.chld[i]
		if get_hovered_list(chld, rel_pos, list) then break end
	end

	return true
end

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@param press_state boolean
---@param press_changed boolean
---@param rel_pos Vector2
---@param true_pos Vector2
---@param sound_pos Vector3
function lib.relative_hover(elem, press_state, press_changed, rel_pos, true_pos, sound_pos)
	local root = elem.root

	---@type FOXStencil.Element[]
	local list = {}

	get_hovered_list(elem, rel_pos, list)

	for i = 1, #list do
		if hover(list[i], root) then break end
	end

	if press_changed then
		for i = 1, #list do
			if press(list[i], root, press_state) then break end
		end
	end

	return #list > 0
end

---@param root FOXStencil.Screen
function lib.reset(root)
	hover(nil, root)
	press(nil, root, was_pressed)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Hover ♡˚
--==============================================================================================================================

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

---@param viewer Player
---@return Vector3 pos
---@return Vector3 dir
local function get_eye_pointer(viewer)
	local pos = viewer:getPos(client.getFrameTime())
		:add(0, viewer:getEyeHeight(), 0)
		:add(viewer:getVariable("eyePos"))
	local dir = viewer:getLookDir()

	return pos, dir
end

------------------------------------------------------------------------------------------------
--#REGION ˚♡ Hover > Screen ♡˚
------------------------------------------------------------------------------------------------

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@return boolean
function lib.screen_hover(elem)
	if not (host:isChatOpen() or action_wheel:isEnabled() or host:isCursorUnlocked()) then return false end

	local press_state, press_changed = get_screen_press()

	local true_pos = client.getMousePos() / client.getGuiScale()
	return lib.relative_hover(elem, press_state, press_changed, true_pos, true_pos, client.getCameraPos())
end

--#ENDREGION -----------------------------------------------------------------------------------
--#REGION ˚♡ Hover > World ♡˚
------------------------------------------------------------------------------------------------

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
---@return boolean
function lib.world_hover(elem)
	local mat = elem.root.part:partToWorldMatrix()

	local viewer = client.getViewer()
	local eye_pos, eye_dir = get_eye_pointer(viewer)
	local press_state, press_changed = get_world_press(viewer)

	local hit = intersectPlane(eye_pos, eye_dir, mat:apply(), mat:applyDir(0, 0, -1))
	if not hit then return false end

	local true_pos = worldToLocal(hit, mat).xy * vec(1, -1)
	return lib.relative_hover(elem, press_state, press_changed, true_pos, true_pos, hit)
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

	local viewer = client.getViewer()
	local eye_pos, eye_dir = get_eye_pointer(viewer)
	local press_state, press_changed = get_world_press(viewer)

	local hit = intersectPlane(eye_pos, eye_dir, mat:apply(), mat:applyDir(0, 0, -1))
	if not hit then return false end

	local true_pos = worldToLocal(hit, mat).xy * vec(1, -1)
	return lib.relative_hover(elem, press_state, press_changed, true_pos, true_pos, hit)
end

return lib

--#ENDREGION

--#ENDREGION
