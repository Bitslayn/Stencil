---@class FOXStencil.Render.Layout
local lib = {}

--[[ TODO
Comment ALL math
Add scale
Add margins
Add text customizations
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
	if elem.skip then return end
	for i = 1, #elem.chld do
		lib.restore(elem.chld[i])
	end

	local props = elem.props
	props.live_pos = props.pos:copy()
	props.live_size = props.size:copy()
	props.live_size_min = props.size_min:copy()
	props.live_size_max = props.size_max:copy()
end

---Recursively calculates size of all children
---@param elem FOXStencil.Element
---@param axis integer
function lib.size(elem, axis)
	if elem.skip then return end
	local a, b = rotate(elem.props)
	local p = pad(elem.props)

	-- Fit label

	-- if elem.props.label ~= "" then
	-- 	local wrd_size = client.getTextDimensions(elem.props.label:gsub("%s", "\n"), 0)
	-- 	elem.props.live_size[axis] = math.max(elem.props.live_size[axis], wrd_size[axis])
	-- end

	-- Fit children

	local size = 0
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.size(chld, axis)

		if a == axis then
			size = size + chld.props.live_size[a]
			elem.props.live_size_min[a] = elem.props.live_size_min[a] + chld.props.live_size_min[a]
		end
		if b == axis then
			elem.props.live_size[b] = math.max(elem.props.live_size[b], chld.props.live_size[b])
			elem.props.live_size_min[b] = math.max(elem.props.live_size_min[b], chld.props.live_size_min[b])
		end
	end
	elem.props.live_size[a] = math.max(elem.props.live_size[a], size)

	-- Gap & Padding

	if a == axis then
		elem.props.live_size[axis] = elem.props.live_size[axis] + elem.props.gap * (#elem.chld - 1)
	end

	elem.props.live_size[axis] = elem.props.live_size[axis] + p[axis][1] + p[axis][2]
end

---Recursively grows child elements
---@param elem FOXStencil.Element
---@param axis integer
function lib.grow(elem, axis)
	if elem.skip then return end
	local a, b = rotate(elem.props)
	local p = pad(elem.props)

	-- Find flexible

	---@type FOXStencil.Element[]
	local flexible = {}

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if a == axis and chld.props.size_flex[a] then
			table.insert(flexible, chld)
		end
		if b == axis and chld.props.size_flex[b] then
			chld.props.live_size[axis] = elem.props.live_size[axis] - p[axis][1] - p[axis][2]
		end
	end

	-- Calculate remaining size

	local rem = elem.props.live_size[a] - p[a][1] - p[a][2]
	for i = 1, #elem.chld do
		rem = rem - elem.chld[i].props.live_size[a]
	end
	rem = rem - elem.props.gap * (#elem.chld - 1)

	-- Grow and shrink along layout

	while rem - rem % .25 ~= 0 and flexible[1] do
		local sign = math.sign(rem)
		local size_l = flexible[1].props.live_size[a]
		local size_r = math.huge
		local add = rem

		-- Find largest children

		for i = 1, #flexible do
			local chld = flexible[i]
			local size = chld.props.live_size[a]
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
			local size = chld.props.live_size[a]
			local prev = size
			if size == size_l then
				size = size + add
				if size <= chld.props.live_size_min[a] or size >= chld.props.live_size_max[a] then
					size = math.clamp(size, chld.props.live_size_min[a], chld.props.live_size_max[a])
					table.remove(flexible, i)
				end
				rem = rem - (size - prev)
				chld.props.live_size[a] = size
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
	if elem.skip then return end
	local a, b = rotate(elem.props)
	local p = pad(elem.props)

	-- Distribute

	local offset = p[a][1]
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if not chld.skip then
			lib.position(chld)

			chld.props.live_pos[a] = chld.props.live_pos[a] + offset
			chld.props.live_pos[b] = chld.props.live_pos[b] + p[b][1]
		end
		offset = offset + chld.props.live_size[a] + elem.props.gap
	end

	-- Align & Justify

	local rem = math.max(elem.props.live_size[a] - offset + elem.props.gap - p[a][2], 0)
	local inner = rem * elem.props.justify
	local outer = rem * -(elem.props.justify - 1)
	local gap = #elem.chld > 1 and inner / (#elem.chld - 1) or 0

	local y = math.max(elem.props.live_size[b] - p[b][1] - p[b][2], 0)

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if not chld.skip then
			chld.props.live_pos[a] = chld.props.live_pos[a] + gap * (i - 1) + (outer * elem.props.align[a])
			chld.props.live_pos[b] = chld.props.live_pos[b] + ((y - chld.props.live_size[b]) * elem.props.align[b])
		end
	end
end

---Creates ModelParts for this element and all of its children recursively
---@param elem FOXStencil.Element
---@param lace number
---@param dist number
function lib.draw(elem, lace, dist)
	if elem.skip then return end

	-- Recurse

	if elem.chld then
		local len = #elem.chld
		for i = 1, len do
			lib.draw(elem.chld[i], dist * i / len, 1 / len)
		end
	end

	-- Draw elements

	elem.props.layer = lace
	elem.skip = true
	elem:draw()
end

---Recursively gets the element hovered over
---@param elem FOXStencil.Element
---@param pos Vector2
---@return FOXStencil.Element?
function lib.hover(elem, pos)
	local props = elem.props
	if not props then return end

	local extend = props.tex_extend
	local tmp_pos = props.live_pos - extend.wx
	local tmp_size = props.live_size + extend.wx + extend.yz
	if not (tmp_pos <= pos and pos <= tmp_pos + tmp_size) then return end

	pos = pos - props.live_pos

	-- Find hovered child element

	if elem.chld then
		if elem.hover_index then
			local res = lib.hover(elem.chld[elem.hover_index], pos)
			if res then return res end
		end
		for i = #elem.chld, 1, -1 do
			local res = lib.hover(elem.chld[i], pos)
			if res then
				elem.hover_index = i
				return res
			end
		end
	end

	-- Interaction

	local root = elem.root

	local swing = client.getViewer():getSwingTime()

	-- Unhover last hovered element

	if root.hovered and root.hovered ~= elem and root.hovered.props.hover then
		root.hovered.props.hover(root.hovered, pos, 0) -- TODO: OUTDATED POSITION
		root.hovered = nil
	end

	if root.clicked and (swing == 0 or 2 < swing) then
		root.clicked.props.click(root.clicked, pos, false) -- TODO: OUTDATED POSITION
		root.clicked = nil
	end

	if not elem then return end

	-- Hover currently hovered element

	if elem.props.hover then
		elem.props.hover(elem, pos, root.hovered == elem and 2 or 1)
		root.hovered = elem
	end

	if not root.clicked and swing == 1 and elem.props.click then
		elem.props.click(elem, pos, true)
		root.clicked = elem
	end

	return elem
end

return lib
