--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---@class FOXStencil.Core.Interact
local hover = {}
local press = {}

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Interact ♡˚
--==============================================================================================================================

---@param elem FOXStencil.Element?
---@param root FOXStencil.Screen
---@param state boolean
---@return boolean
local function call_press(elem, root, state)
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
local function call_hover(elem, root, state)
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
local function get_hovered_elem(list, elem, elem_pos, root_pos, wrld_pos)
	local pos = elem.state.pos
	local size = elem.state.size

	elem.pointer.elem_pos = elem_pos - pos
	elem.pointer.root_pos = root_pos:copy()
	elem.pointer.wrld_pos = wrld_pos:copy()

	if not (pos <= elem_pos and elem_pos <= pos + size and elem.props.visible) then return false end

	list[#list + 1] = elem
	elem_pos = elem_pos - pos


	for i = #elem.chld, 1, -1 do
		if get_hovered_elem(list, elem.chld[i], elem_pos, root_pos, wrld_pos) then break end
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
local function elem_hover(elem, press_state, press_changed, elem_pos, root_pos, wrld_pos)
	local root = elem.root

	local move_pos = root_pos - root.pointer.root_pos

	root.pointer.elem_pos = elem_pos:copy()
	root.pointer.root_pos = root_pos:copy()
	root.pointer.wrld_pos = wrld_pos:copy()

	---@type FOXStencil.Element[]
	local list = {}

	if root.pressed and root.pressed.events.drag then
		root.pressed.pointer.elem_pos = root.pressed.pointer.elem_pos + move_pos
		root.pressed.pointer.root_pos = root_pos:copy()
		root.pressed.pointer.wrld_pos = wrld_pos:copy()

		list = { root.pressed }
		root.pressed.events.drag(root.pressed, move_pos)
	else
		get_hovered_elem(list, elem, elem_pos, root_pos, wrld_pos)
	end

	for i = 1, #list do
		if call_hover(list[i], root, i == #list) then break end
	end

	if press_changed then
		for i = 1, #list do
			if call_press(list[i], root, press_state) then break end
		end
	end

	return #list > 0
end

---Finds the hovered window and calls elem_hover
---@param screen FOXStencil.Screen
---@param elem_pos Vector2
---@return FOXStencil.Element? elem
local function get_hovered_window(screen, elem_pos)
	for i = #screen.chld, 1, -1 do
		local elem = screen.chld[i]

		local pos = elem.state.pos
		local size = elem.state.size

		if pos <= elem_pos and elem_pos <= pos + size and elem.props.visible then
			return elem
		end
	end
end

---@type FOXStencil.Screen
local hovered_screen

---@type {depth: number, screen: FOXStencil.Screen}[]
local hovering = {}

function events.post_render(_, ctx)
	if ctx == "PAPERDOLL" then return end

	local min = math.huge
	local screen
	for i = 1, #hovering do
		if hovering[i].depth < min then
			min = hovering[i].depth
			screen = hovering[i].screen
		end
	end

	if not screen then
		local press_state, press_changed = press.world_press()
		if press_changed then
			hover.reset(hovered_screen)
		end
		return
	end
	hovered_screen = screen
	hovering = {}
end

---@param screen FOXStencil.Screen
---@param press_consumer function
---@param elem_pos Vector2
---@param root_pos Vector2
---@param wrld_pos Vector3
---@param depth number
---@return boolean
local function screen_hover(screen, press_consumer, elem_pos, root_pos, wrld_pos, depth)
	local focused = screen.pressed and screen.pressed.events.drag ~= nil

	local elem = get_hovered_window(screen, elem_pos)
	if focused then
		depth = 0
		elem = screen.pressed
	end

	if not elem then return false end

	hovering[#hovering + 1] = { depth = depth, screen = screen }
	if hovered_screen ~= screen then return false end

	local press_state, press_changed = press_consumer()
	return elem_hover(elem, press_state, press_changed, elem_pos, root_pos, wrld_pos)
end

---@param root FOXStencil.Screen
function hover.reset(root)
	call_hover(nil, root, true)
	call_press(nil, root, press.was_pressed)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Press ♡˚
--==============================================================================================================================

press.was_pressed = false

---@type boolean
local mouse_press
function events.mouse_press(_, state)
	mouse_press = state ~= 0 or false
end

---Returns if the host is pressing the screen
---@return boolean state
---@return boolean change
function press.gui_press()
	if press.was_pressed == mouse_press then return mouse_press, false end
	press.was_pressed = mouse_press

	return mouse_press, true
end

---Returns if the viewer started swinging or using an item
---@return boolean state
---@return boolean change
function press.world_press()
	local viewer = client.getViewer()

	local swing_time = viewer:getSwingTime()
	local is_pressed = 0 < swing_time and swing_time < 3 or viewer:isUsingItem()
	if press.was_pressed == is_pressed then return is_pressed, false end
	press.was_pressed = is_pressed

	return is_pressed, true
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Hover ♡˚
--==============================================================================================================================

-- Written by 4P5 ★

local EPSILON = 2.2204460492503131e-16
local dot = vectors.vec3().dot

---@param ray_pos Vector3
---@param ray_dir Vector3
---@param plane_pos Vector3
---@param plane_normal Vector3
---@return Vector3? hit_pos
---@return number? depth
local function intersect_plane(ray_pos, ray_dir, plane_pos, plane_normal)
	local denom = dot(plane_normal, ray_dir)
	if -denom < EPSILON then return end
	local d = plane_pos - ray_pos
	local t = dot(d, plane_normal) / denom
	if t < EPSILON then return end
	local hit_pos = ray_pos + ray_dir * t
	return hit_pos, (ray_pos - hit_pos):length()
end

------------------------------------------------------------------------------------------------
--#REGION ˚♡ Hover > Screen ♡˚
------------------------------------------------------------------------------------------------

---Recursively gets the element hovered over
---@param screen FOXStencil.Screen
---@return boolean is_hovered
function hover.gui_hover(screen)
	local mouse_visible = host:isChatOpen() or host:isCursorUnlocked()
	if not mouse_visible then return false end

	local root_pos = client.getMousePos() / client.getGuiScale()

	local is_hovered = screen_hover(screen, press.gui_press, root_pos, root_pos, client.getCameraPos(), 0)
	return is_hovered
end

--#ENDREGION -----------------------------------------------------------------------------------
--#REGION ˚♡ Hover > World ♡˚
------------------------------------------------------------------------------------------------

---Recursively gets the element hovered over
---@param screen FOXStencil.Screen
---@return boolean is_hovered
function hover.world_hover(screen)
	local mat = screen.part:partToWorldMatrix()

	local hit, depth = intersect_plane(client.getCameraPos(), client.getCameraDir(), mat:apply(), mat:applyDir(0, 0, -1))
	if not hit then return false end

	local root_pos = mat:inverted():apply(hit).xy * vec(-1, -1)

	local is_hovered = screen_hover(screen, press.world_press, root_pos, root_pos, hit, depth --[[@as number]])
	return is_hovered
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
---@param screen FOXStencil.Screen
---@param block BlockState
---@return boolean is_hovered
function hover.skull_hover(screen, block)
	local pos = block.id:find("wall") and vec(0, -0.25, 0.25) or vec(0, -0.5, 0)
	local rot = tonumber(block.properties.rotation) or face[block.properties.facing]

	local mat = matrices.translate4(block:getPos() + 0.5)
		* matrices.rotation4(0, rot and rot * -22.5 or 0, 0)
		* matrices.translate4(pos)
		* matrices.scale4(1 / 16)
		* screen.part:getParent():getPositionMatrixRaw()

	local hit, depth = intersect_plane(client.getCameraPos(), client.getCameraDir(), mat:apply(), mat:applyDir(0, 0, -1))
	if not hit then return false end

	local root_pos = -mat:inverted():apply(hit).xy

	local is_hovered = screen_hover(screen, press.world_press, root_pos, root_pos, hit, depth --[[@as number]])
	return is_hovered
end

--#ENDREGION

--#ENDREGION

return hover
