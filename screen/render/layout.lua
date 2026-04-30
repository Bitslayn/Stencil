---@class FOXStencil.Render.Layout
local lib = {}

-- Referenced from Nic Barker's Clay algorithm
-- https://www.youtube.com/watch?v=by9lQvpvMIc

---@param props FOXStencil.Element.Props
---@return integer, integer
local function rotate(props)
	local dir = props.vertical and 2 or 1
	local a = dir
	local b = dir % 2 + 1

	return a, b
end

---@param props FOXStencil.Element.Props
---@return [{[1]: number, [2]: number}, {[1]: number, [2]: number}]
local function pad(props)
	return {
		{ props.padding[4], props.padding[2] }, -- x: left, right
		{ props.padding[1], props.padding[3] }, -- y: top, bottom
	}
end

---@param elem FOXStencil.Element
function lib.restore(elem)
	if elem.skip.layout then return end
	if not elem.state.visible then return end
	for i = 1, #elem.chld do
		lib.restore(elem.chld[i])
	end

	local props = elem:getProps()
	local state = elem.state
	state.calc_pos = { props.pos:unpack() }
	state.calc_size = { props.size:unpack() }
	state.calc_size_min = { props.size_min:unpack() }
	state.calc_size_max = { props.size_max:unpack() }

	if props.label ~= "" then
		local width = client.getTextWidth(string.gsub(props.label, "%s", "\n"))
			* props.label_size + props.label_margin.w + props.label_margin.y
		state.calc_size[1] = math.max(state.calc_size[1], width)
		state.calc_size_min[1] = math.max(state.calc_size_min[1], width)
	end
end

---Recursively calculates size of all children
---@param elem FOXStencil.Element
---@param axis integer
function lib.size(elem, axis)
	if elem.skip.layout then return end
	if not elem.state.visible then return end
	local props = elem:getProps()
	local state = elem.state

	local a, b = rotate(props)
	local p = pad(props)

	-- Fit children

	local size = 0
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if chld.state.visible then
			lib.size(chld, axis)

			if not chld:getProps().absolute_pos then
				if a == axis then
					size = size + chld.state.calc_size[a]
					state.calc_size_min[a] = state.calc_size_min[a] + chld.state.calc_size_min[a]
				end
				if b == axis then
					state.calc_size[b] = math.max(state.calc_size[b], chld.state.calc_size[b])
					state.calc_size_min[b] = math.max(state.calc_size_min[b], chld.state.calc_size_min[b])
				end
			end
		end
	end
	state.calc_size[a] = math.max(state.calc_size[a], size)

	-- Gap & Padding

	if a == axis then
		local inner = props.gap * (#elem.chld - 1)
		state.child_span = size + inner
		state.calc_size[axis] = state.calc_size[axis] + inner
	end

	state.calc_size[axis] = state.calc_size[axis] + p[axis][1] + p[axis][2]

	-- Fit label

	if props.label ~= "" and axis == 2 then
		local wrd_size = client.getTextDimensions(props.label, state.calc_size[1])
			* props.label_size + props.label_margin.wx + props.label_margin.yz --[[@as Vector2]]
		state.calc_size[2] = math.max(state.calc_size[2], state.calc_size_min[2], wrd_size.y)
	end
end

---Recursively grows child elements
---@param elem FOXStencil.Element
---@param axis integer
function lib.grow(elem, axis)
	if elem.skip.layout then return end
	if not elem.state.visible then return end
	local props = elem:getProps()
	local state = elem.state
	local a, b = rotate(props)
	local p = pad(props)

	-- Find flexible

	---@type FOXStencil.Element[]
	local flexible = {}

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if a == axis and chld:getProps().size_flex[a] then
			table.insert(flexible, chld)
		end
		if b == axis and chld:getProps().size_flex[b] then
			chld.state.calc_size[axis] = state.calc_size[axis] - p[axis][1] - p[axis][2]
		end
	end

	-- Calculate remaining size

	local rem = state.calc_size[a] - p[a][1] - p[a][2]
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if not chld:getProps().absolute_pos then
			rem = rem - chld.state.calc_size[a]
		end
	end
	rem = rem - props.gap * (#elem.chld - 1)

	-- Grow and shrink along layout

	while rem - rem % .25 ~= 0 and flexible[1] do
		local sign = math.sign(rem)
		local size_l = flexible[1].state.calc_size[a]
		local size_r = math.huge
		local add = rem

		-- Find largest children

		for i = 1, #flexible do
			local chld = flexible[i]
			local size = chld.state.calc_size[a]
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
			local size = chld.state.calc_size[a]
			local prev = size
			if size == size_l then
				size = size + add
				if size <= chld.state.calc_size_min[a] or size >= chld.state.calc_size_max[a] then
					size = math.clamp(size, chld.state.calc_size_min[a], chld.state.calc_size_max[a])
					table.remove(flexible, i)
				end
				rem = rem - (size - prev)
				chld.state.calc_size[a] = size
			end
		end
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
	if elem.skip.layout then return end
	if not elem.state.visible then return end
	local props = elem:getProps()
	local a, b = rotate(props)
	local p = pad(props)

	local offset = math.lerp(
		p[a][1],
		elem.state.calc_size[a] - elem.state.child_span - p[a][2],
		props.align[a]
	)

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if chld.state.visible and not chld.skip.layout then
			lib.position(chld)

			if not chld:getProps().absolute_pos then
				chld.state.calc_pos[a] = chld.state.calc_pos[a] + offset
				chld.state.calc_pos[b] = math.lerp(
					chld.state.calc_pos[b] + p[b][1],
					elem.state.calc_size[b] - chld.state.calc_size[b] - p[b][2],
					props.align[b]
				)

				offset = offset + chld.state.calc_size[a] + props.gap
			end
		end
	end
end

---Creates ModelParts for this element and all of its children recursively
---@param elem FOXStencil.Element
---@param lace number
---@param dist number
function lib.draw(elem, lace, dist)
	if elem.skip.layout then return end

	elem.state.pos = vectors.vec2(table.unpack(elem.state.calc_pos))
	elem.state.size = vectors.vec2(table.unpack(elem.state.calc_size))
	elem.state.size_min = vectors.vec2(table.unpack(elem.state.calc_size_min))
	elem.state.size_max = vectors.vec2(table.unpack(elem.state.calc_size_max))

	-- Recurse

	local len = #elem.chld
	for i = 1, len do
		local chld = elem.chld[i]
		lib.draw(chld, chld:getProps().absolute_pos and (i - 1) * 2 or dist * i / len, 1 / len)
	end

	-- Draw elements

	elem.props.layer = lace
	elem:draw()
	elem.skip.layout = true
	elem.skip.redraw = true
end

return lib
