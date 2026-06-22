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
---@return boolean
local function do_hover(elem, root)
	-- Leave last element

	local hovered = root.hovered
	if hovered and hovered ~= elem then
		hovered.events.hover(hovered, false)
	end

	-- Enter current element

	if not elem then return false end

	if elem.events.hover and not elem.events.hover(elem, true) then
		elem.root.hovered = elem
		return true
	end

	return false
end

---@param elem FOXStencil.Element?
---@param root FOXStencil.Screen
---@param state boolean
---@return boolean
local function do_press(elem, root, state)
	-- Release last element

	local pressed = root.pressed
	if pressed and not state then
		pressed.events.press(pressed, false)
	end

	-- Press current element

	if not elem then return false end

	if state and elem.events.press and not elem.events.press(elem, true) then
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
local function get_hovered(elem, rel_pos, list)
	local pos = elem.state.pos
	local size = elem.state.size

	if not (pos <= rel_pos and rel_pos <= pos + size and elem.props.visible) then return false end

	list[#list + 1] = elem
	rel_pos = rel_pos - pos

	for i = #elem.chld, 1, -1 do
		local chld = elem.chld[i]
		if get_hovered(chld, rel_pos, list) then break end
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

	get_hovered(elem, rel_pos, list)

	for i = 1, #list do
		if do_hover(list[i], root) then break end
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
	do_hover(nil, root)
	do_press(nil, root, was_pressed)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Hover ♡˚
--==============================================================================================================================

-- Written by 4P5 ★

local EPSILON = 2.2204460492503131e-16
local dot = vectors.vec3().dot

---@param mat Matrix4
---@return Vector3? intersection_point
local function intersect_plane(mat)
	local ray_pos = client.getCameraPos()
	local ray_dir = client.getCameraDir()

	local plane_pos = mat:apply()
	local plane_normal = mat:applyDir(0, 0, -1)

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

	local true_pos = client.getMousePos() / client.getGuiScale()
	return lib.relative_hover(elem, press_state, press_changed, true_pos, true_pos, client.getCameraPos())
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

	local hit = intersect_plane(mat)
	if not hit then return false end

	local true_pos = mat:inverted():apply(hit).xy * vec(1, -1)
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

	local press_state, press_changed = get_world_press()

	local hit = intersect_plane(mat)
	if not hit then return false end

	local true_pos = -mat:inverted():apply(hit).xy
	return lib.relative_hover(elem, press_state, press_changed, true_pos, true_pos, hit)
end

return lib

--#ENDREGION

--#ENDREGION
