---@diagnostic disable: invisible

---@class FOXStencil.Core.Layout
local lib = {}

-- Referenced from Nic Barker's Clay algorithm
-- https://www.youtube.com/watch?v=by9lQvpvMIc

---@param elem FOXStencil.Element
function lib.restore(elem)
	if not elem.queued then return end
	if not elem.props.visible then return end
	for i = 1, #elem.chld do
		lib.restore(elem.chld[i])
	end

	local props = elem.props
	local state = elem.state

	local dir = props.direction == "VERTICAL" and 2 or 1

	state.elem_axis = { dir, dir % 2 + 1 }
	state.elem_pad = {
		{ props.padding[4], props.padding[2] }, -- x: left, right
		{ props.padding[1], props.padding[3] }, -- y: top, bottom
	}
end

---Recursively calculates size of all children
---@param elem FOXStencil.Element
---@param axis integer
function lib.size(elem, axis)
	if not elem.queued then return end
	if not elem.props.visible then return end
	local props = elem.props
	local state = elem.state
	local a, b = table.unpack(state.elem_axis)
	local p = state.elem_pad

	-- Restore

	if axis == 1 then
		state.raw_size = { props.size:unpack() }
		state.raw_size_min = { props.size_min:unpack() }
		state.raw_size_max = { props.size_max:unpack() }

		state.size_flex = { state.raw_size[1] < 0, state.raw_size[2] < 0 }
	end

	-- Wrap element

	if state.size_flex[axis] then
		local wrap = elem.events.wrap(elem, state.raw_size[1])
		local x, y = (wrap or vectors.vec2()):unpack()

		if axis == 1 then
			state.raw_size_max[1] = math.min(state.raw_size_max[1], x)
		else
			state.raw_size[2] = y or 0
			state.raw_size_max[2] = math.min(state.raw_size_max[2], y)
		end
	end

	-- Fit children

	local size = 0
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if chld.props.visible then
			lib.size(chld, axis)

			if axis == a then
				size = size + chld.state.raw_size[a]
				state.raw_size_min[a] = state.raw_size_min[a] + chld.state.raw_size_min[a]
			else
				state.raw_size[b] = math.max(state.raw_size[b], chld.state.raw_size[b])
				state.raw_size_min[b] = math.max(state.raw_size_min[b], chld.state.raw_size_min[b])
			end
		end
	end
	state.raw_size[a] = math.max(state.raw_size[a], size)
	state.raw_size[axis] = math.max(state.raw_size[axis], state.raw_size_min[axis])

	-- Gap & Padding

	if axis == a then
		local inner = props.gap * (#elem.chld - 1)
		state.child_span = size + inner
		state.raw_size[axis] = state.raw_size[axis] + inner
	end

	state.raw_size[axis] = state.raw_size[axis] + p[axis][1] + p[axis][2]
end

---Recursively grows child elements
---@param elem FOXStencil.Element
---@param axis integer
function lib.grow(elem, axis)
	if not elem.queued then return end
	if not elem.props.visible then return end
	local props = elem.props
	local state = elem.state
	local a, b = table.unpack(state.elem_axis)
	local p = state.elem_pad

	-- Find flexible

	---@type FOXStencil.Element[]
	local flexible = {}

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if chld.state.size_flex[axis] then
			if axis == a then
				flexible[#flexible + 1] = chld
			else
				chld.state.raw_size[b] = math.min(chld.state.raw_size_max[b], state.raw_size[b] - (p[b][1] + p[b][2]))
			end
		end
	end

	-- Calculate remaining size

	local rem = state.raw_size[a] - (p[a][1] + p[a][2])
	for i = 1, #elem.chld do
		local chld = elem.chld[i]

		rem = rem - chld.state.raw_size[a]
	end
	rem = rem - props.gap * (#elem.chld - 1)

	-- Grow and shrink along layout

	while rem ~= 0 and flexible[1] do
		local sign = math.sign(rem)
		local size_l = flexible[1].state.raw_size[a]
		local size_r = math.huge
		local add = rem

		-- Find largest children

		for i = 1, #flexible do
			local chld = flexible[i]
			local size = chld.state.raw_size[a]
			if size ~= size_l then
				if sign * size < sign * size_l then
					size_r = size_l
					size_l = size
				else
					size_r = math.min(size_r, size)
					add = size_r - size_l
				end
			end
		end

		-- Distributes remaining size

		add = math.min(add, rem / #flexible)

		-- Grows or shrinks largest children evenly, and pops off children that cannot be sized further
		-- Dev note: ipairs used here since indexes get removed from this table

		for i, chld in ipairs(flexible) do
			local size = chld.state.raw_size[a]
			local prev = size
			if size == size_l then
				size = size + add
				if size <= chld.state.raw_size_min[a] or size >= chld.state.raw_size_max[a] then
					size = math.clamp(size, chld.state.raw_size_min[a], chld.state.raw_size_max[a])
					table.remove(flexible, i)
				end
				rem = rem - (size - prev)
				chld.state.raw_size[a] = size
			end
		end

		rem = rem - rem % 0.05
	end

	-- Recurse children

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.grow(chld, axis)
	end
end

---Recursively calculates position of all children
---@param elem FOXStencil.Element
function lib.position(elem)
	if not elem.queued then return end
	if not elem.props.visible then return end
	local props = elem.props
	local state = elem.state
	local a, b = table.unpack(state.elem_axis)
	local p = state.elem_pad

	-- Restore

	state.raw_pos = { props.pos:unpack() }

	local offset = math.lerp(
		p[a][1],
		elem.state.raw_size[a] - elem.state.child_span - p[a][2],
		props.align[a]
	)

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if chld.props.visible and chld.queued then
			lib.position(chld)

			chld.state.raw_pos[a] = chld.state.raw_pos[a] + offset
			chld.state.raw_pos[b] = math.lerp(
				chld.state.raw_pos[b] + p[b][1],
				elem.state.raw_size[b] - chld.state.raw_size[b] - p[b][2],
				props.align[b]
			)

			offset = offset + chld.state.raw_size[a] + props.gap
		end
	end
end

---Creates ModelParts for this element and all of its children recursively
---@param elem FOXStencil.Element
---@param lace number
---@param dist number
function lib.draw(elem, lace, dist)
	if not elem.queued then return end

	local size = elem.state.size

	elem.state.pos = vectors.vec2(table.unpack(elem.state.raw_pos))
	elem.state.size = vectors.vec2(table.unpack(elem.state.raw_size))
	elem.state.size_min = vectors.vec2(table.unpack(elem.state.raw_size_min))
	elem.state.size_max = vectors.vec2(table.unpack(elem.state.raw_size_max))

	local diff = elem.state.size ~= size

	-- Recurse

	local len = #elem.chld
	for i = 1, len do
		local chld = elem.chld[i]
		lib.draw(chld, dist * i / len, 1 / len)
	end

	-- Draw elements

	elem.queued = false
	elem.part:pos(-elem.state.pos:augmented(lace)):visible(elem.props.visible)
	if diff then
		elem.events.draw(elem)
	end
end

return lib
