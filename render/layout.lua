---@class FOXStencil.Render.Layout
local lib = {}

--[[ TODO
Move everything to methods and flat properties (basically cleanup)
Comment ALL math
Add scale
Add margins
Add text customizations
Figure out widgets
]]

--[[Rules for future clay optimization
Elements are updated from their leaves upwards
Any element can report that they've been updated in some way. During recursion, if an element hasn't reported they've been updated, that element can be skipped entirely.
A parent can tell its immediate children to update if child styles have been changed. This can only be triggered by the user.
A child can tell its parent to update if the child has been resized in some way
A child can tell its siblings that *they* should update if the child has been resized in some way, and these siblings are ordered later than this element
]]

---@param styl Stencil.Styles.Internal
---@return integer, integer
local function rotate(styl)
	local dir = string.find(styl.dir, "^[Vvy]") and 2 or 1
	local a = dir
	local b = dir % 2 + 1

	return a, b
end

---@param styl Stencil.Styles.Internal
---@return [{[1]: number, [2]: number}, {[1]: number, [2]: number}]
local function pad(styl)
	return {
		{ styl.padding[4], styl.padding[2] }, -- x: left, right
		{ styl.padding[1], styl.padding[3] }, -- y: top, bottom
	}
end

---@param elem Stencil.Element
function lib.restore(elem)
	if elem.skip then return end
	for i = 1, #elem.chld do
		lib.restore(elem.chld[i])
	end

	local size = elem.styl.size

	elem.stat = {
		pos = elem.styl.pos:copy(),
		size = vec(size[1].val, size[2].val),
		size_min = vec(size[1].min, size[2].min),
		size_max = vec(size[1].max, size[2].max),
	}
end

---Recursively calculates size of all children
---@param elem Stencil.Element
---@param axis integer
function lib.size(elem, axis)
	if elem.skip then return end
	local a, b = rotate(elem.styl)
	local p = pad(elem.styl)

	-- Fit children

	local size = 0
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.size(chld, axis)

		if a == axis then
			size = size + chld.stat.size[a]
			elem.stat.size_min[a] = elem.stat.size_min[a] + chld.stat.size_min[a]
		end
		if b == axis then
			elem.stat.size[b] = math.max(elem.stat.size[b], chld.stat.size[b])
			elem.stat.size_min[b] = math.max(elem.stat.size_min[b], chld.stat.size_min[b])
		end
	end
	elem.stat.size[a] = math.max(elem.stat.size[a], size)

	-- Gap & Padding

	if a == axis then
		elem.stat.size[axis] = elem.stat.size[axis] + elem.styl.gap * (#elem.chld - 1)
	end

	elem.stat.size[axis] = elem.stat.size[axis] + p[axis][1] + p[axis][2]
end

---Recursively grows child elements
---@param elem Stencil.Element
---@param axis integer
function lib.grow(elem, axis)
	if elem.skip then return end
	local a, b = rotate(elem.styl)
	local p = pad(elem.styl)

	-- Find flexible

	---@type Stencil.Element[]
	local flexible = {}

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if a == axis and string.find(chld.styl.size[a].mode, "^[Gg]") then
			table.insert(flexible, chld)
		end
		if b == axis and string.find(chld.styl.size[b].mode, "^[Gg]") then
			chld.stat.size[axis] = elem.stat.size[axis] - p[axis][1] - p[axis][2]
		end
	end

	-- Calculate remaining size

	local rem = elem.stat.size[a] - p[a][1] - p[a][2]
	for i = 1, #elem.chld do
		rem = rem - elem.chld[i].stat.size[a]
	end
	rem = rem - elem.styl.gap * (#elem.chld - 1)

	-- Grow and shrink along layout

	while rem - rem % .25 ~= 0 and flexible[1] do
		local sign = math.sign(rem)
		local size_l = flexible[1].stat.size[a]
		local size_r = math.huge
		local add = rem

		-- Find largest children

		for i = 1, #flexible do
			local chld = flexible[i]
			local size = chld.stat.size[a]
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
			local size = chld.stat.size[a]
			local prev = size
			if size == size_l then
				size = size + add
				if size <= chld.stat.size_min[a] or size >= chld.stat.size_max[a] then
					size = math.clamp(size, chld.stat.size_min[a], chld.stat.size_max[a])
					table.remove(flexible, i)
				end
				rem = rem - (size - prev)
				chld.stat.size[a] = size
			end
		end
	end

	-- Recurse children

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.grow(chld, axis)
	end
end

---@param elem Stencil.Element
function lib.wrap(elem)
	-- if elem.type == "label" then
	-- 	elem.stat.size = client.getTextDimensions(elem.stat.text, elem.stat.size.x)
	-- elseif elem.type == "sprite" then
	-- 	local dim = elem.stat.texture --[[@as Texture]]:getDimensions()
	-- 	elem.stat.size.y = dim.y / dim.x * elem.stat.size.x
	-- elseif elem.chld[1] then
	-- 	for i = 1, #elem.chld do
	-- 		local chld = elem.chld[i]
	-- 		lib.wrap(chld)
	-- 	end
	-- end
end

---Recursively calculates position of all children
---@param elem Stencil.Element
function lib.position(elem)
	if elem.skip then return end
	local a, b = rotate(elem.styl)
	local p = pad(elem.styl)

	-- Distribute

	local offset = p[a][1]
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if not chld.skip then
			lib.position(chld)

			chld.stat.pos[a] = chld.stat.pos[a] + offset
			chld.stat.pos[b] = chld.stat.pos[b] + p[b][1]
		end
		offset = offset + chld.stat.size[a] + elem.styl.gap
	end

	-- Align & Justify

	local rem = math.max(elem.stat.size[a] - offset + elem.styl.gap - p[a][2], 0)
	local inner = rem * elem.styl.justify
	local outer = rem * -(elem.styl.justify - 1)
	local gap = #elem.chld > 1 and inner / (#elem.chld - 1) or 0

	local y = math.max(elem.stat.size[b] - p[b][1] - p[b][2], 0)

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if not chld.skip then
			chld.stat.pos[a] = chld.stat.pos[a] + gap * (i - 1) + (outer * elem.styl.align[a])
			chld.stat.pos[b] = chld.stat.pos[b] + ((y - chld.stat.size[b]) * elem.styl.align[b]) -
				(elem.styl.texture and elem.styl.texture.extend[1] or 0)
		end
	end
end

---Creates ModelParts for this element and all of its children recursively
---@param elem Stencil.Element
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

	if not elem.elem then return end

	elem.elem:draw(lace)
	elem.skip = true
end

---Recursively gets the element hovered over
---@param elem Stencil.Element
---@param pos Vector2
---@return Stencil.Element?
function lib.hover(elem, pos)
	local stat = elem.stat
	if not stat then return end

	local extend = elem.styl.texture and elem.styl.texture.extend or vectors.vec4()
	local tmp_pos = stat.pos - extend.wx
	local tmp_size = stat.size + extend.wx + extend.yz
	if not (tmp_pos <= pos and pos <= tmp_pos + tmp_size) then return end

	pos = pos - stat.pos

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

	while elem do
		if elem.styl.hover or elem.styl.click then break end
		pos = pos + elem.stat.pos
		elem = elem.parn
	end

	local swing = player:getSwingTime()

	-- Unhover last hovered element

	if root.hovered and root.hovered ~= elem and root.hovered.styl.hover then
		root.hovered.styl.hover(root.hovered, pos, 0) -- TODO: OUTDATED POSITION
		root.hovered = nil
	end

	if root.clicked and (swing == 0 or 2 < swing) then
		root.clicked.styl.click(root.clicked, pos, false) -- TODO: OUTDATED POSITION
		root.clicked = nil
	end

	if not elem then return end

	-- Hover currently hovered element

	if elem.styl.hover then
		elem.styl.hover(elem, pos, root.hovered == elem and 2 or 1)
		root.hovered = elem
	end

	if not root.clicked and swing == 1 and elem.styl.click then
		elem.styl.click(elem, pos, true)
		root.clicked = elem
	end

	return elem
end

return lib
