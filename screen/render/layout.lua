---@class FOXStencil.Render.Layout
local lib = {}

--[[ Final TODO
Add locked element positioning mode
Migrate to layer system
Finish all widgets
Comment and document everything
]]

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
	state.pos = props.pos:copy()
	state.size = props.size:copy()
	state.size_min = props.size_min:copy()
	state.size_max = props.size_max:copy()

	if props.label ~= "" then
		local width = client.getTextWidth(string.gsub(props.label, "%s", "\n"))
			* props.label_size + props.label_margin.w + props.label_margin.y
		state.size.x = math.max(state.size.x, width)
		state.size_min.x = math.max(state.size_min.x, width)
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

			if a == axis then
				size = size + chld.state.size[a]
				state.size_min[a] = state.size_min[a] + chld.state.size_min[a]
			end
			if b == axis then
				state.size[b] = math.max(state.size[b], chld.state.size[b])
				state.size_min[b] = math.max(state.size_min[b], chld.state.size_min[b])
			end
		end
	end
	state.size[a] = math.max(state.size[a], size)

	-- Gap & Padding

	if a == axis then
		state.size[axis] = state.size[axis] + props.gap * (#elem.chld - 1)
	end

	state.size[axis] = state.size[axis] + p[axis][1] + p[axis][2]

	-- Fit label

	if props.label ~= "" and axis == 2 then
		local wrd_size = client.getTextDimensions(props.label, state.size.x)
			* props.label_size + props.label_margin.wx + props.label_margin.yz --[[@as Vector2]]
		state.size.y = math.max(state.size_min.y, wrd_size.y)
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
			chld.state.size[axis] = state.size[axis] - p[axis][1] - p[axis][2]
		end
	end

	-- Calculate remaining size

	local rem = state.size[a] - p[a][1] - p[a][2]
	for i = 1, #elem.chld do
		rem = rem - elem.chld[i].state.size[a]
	end
	rem = rem - props.gap * (#elem.chld - 1)

	-- Grow and shrink along layout

	while rem - rem % .25 ~= 0 and flexible[1] do
		local sign = math.sign(rem)
		local size_l = flexible[1].state.size[a]
		local size_r = math.huge
		local add = rem

		-- Find largest children

		for i = 1, #flexible do
			local chld = flexible[i]
			local size = chld.state.size[a]
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

		for i, chld in ipairs(flexible) do
			local size = chld.state.size[a]
			local prev = size
			if size == size_l then
				size = size + add
				if size <= chld.state.size_min[a] or size >= chld.state.size_max[a] then
					size = math.clamp(size, chld.state.size_min[a], chld.state.size_max[a])
					table.remove(flexible, i)
				end
				rem = rem - (size - prev)
				chld.state.size[a] = size
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

	-- Distribute

	local offset = p[a][1]
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if chld.state.visible and not chld.skip.layout then
			lib.position(chld)

			chld.state.pos[a] = chld.state.pos[a] + offset
			chld.state.pos[b] = chld.state.pos[b] + p[b][1]
		end
		offset = offset + chld.state.size[a] + props.gap
	end

	-- Align & Justify

	local rem = math.max(elem.state.size[a] - offset + props.gap - p[a][2], 0)
	local inner = rem * props.justify
	local outer = rem * -(props.justify - 1)
	local gap = #elem.chld > 1 and inner / (#elem.chld - 1) or 0

	local y = math.max(elem.state.size[b] - p[b][1] - p[b][2], 0)

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if chld.state.visible and not chld.skip.layout then
			chld.state.pos[a] = chld.state.pos[a] + gap * (i - 1) + (outer * props.align[a])
			chld.state.pos[b] = chld.state.pos[b] + ((y - chld.state.size[b]) * props.align[b])
		end
	end
end

---Creates ModelParts for this element and all of its children recursively
---@param elem FOXStencil.Element
---@param lace number
---@param dist number
function lib.draw(elem, lace, dist)
	if elem.skip.layout then return end

	-- Recurse

	local len = #elem.chld
	for i = 1, len do
		lib.draw(elem.chld[i], dist * i / len, 1 / len)
	end

	-- Draw elements

	elem.props.layer = lace
	elem:draw()
	elem.skip.layout = true
	elem.skip.redraw = true
end

return lib
