---@class FOXStencil.Render.Layout
local lib = {}

--[[
All child element positions are relative to their parent
The parent element size depends on its children
Calculate width first before wrapping text and then calculate height
]]

--[[ TODO
Find and fix padding bug
Experiment with slice gutters for overlapping buttons
OPTIMIZE OPTIMIZE OPTIMIZE
Comment ALL math
Add scale
Add text customizations
Figure out widgets
Add hover detection
]]

---@param styl FOXStencil.Styles.Any
---@return integer, integer
local function rotate(styl)
	local dir = string.find(styl.dir, "^[Vvy]") and 2 or 1
	local a = dir
	local b = dir % 2 + 1

	return a, b
end

---@param styl FOXStencil.Styles.Any
---@return [{[1]: number, [2]: number}, {[1]: number, [2]: number}]
local function pad(styl)
	return {
		{ styl.pad[4], styl.pad[2] }, -- x: left, right
		{ styl.pad[1], styl.pad[3] }, -- y: top, bottom
	}
end

---Recursively calculates size of all children
---@param elem FOXStencil.Element.Any
---@param axis integer
function lib.size(elem, axis)
	if not elem.chld then return end
	local a, b = rotate(elem.styl)

	-- Fit children

	local size = 0
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.size(chld, axis)

		if a == axis then
			size = size + chld.styl.size[a]
			elem.styl.sizing[a].min = elem.styl.sizing[a].min + chld.styl.sizing[a].min
		end
		if b == axis then
			elem.styl.size[b] = math.max(elem.styl.size[b], chld.styl.size[b])
			elem.styl.sizing[b].min = math.max(elem.styl.sizing[b].min, chld.styl.sizing[b].min)
		end
	end
	elem.styl.size[a] = math.max(elem.styl.size[a], size)

	-- Gap & Padding

	if a == axis then
		elem.styl.size[a] = elem.styl.size[a] + elem.styl.gap * (#elem.chld - 1)
	end

	if axis == 1 then
		elem.styl.size.x = elem.styl.size.x + elem.styl.pad[2] + elem.styl.pad[4]
	else
		elem.styl.size.y = elem.styl.size.y + elem.styl.pad[1] + elem.styl.pad[3]
	end
end

---@param tbl FOXStencil.Element.Any[]
---@param axis any
---@param rem number
---@return number rem
local function grow(tbl, axis, rem)
	return rem
end

---Recursively grows child elements
---@param elem FOXStencil.Element.Any
---@param axis integer
function lib.grow(elem, axis)
	if not elem.chld then return end
	local a, b = rotate(elem.styl)
	local p = pad(elem.styl)

	-- Find growable and shrinkable

	---@type FOXStencil.Element.Any[]
	local growable = {}
	---@type FOXStencil.Element.Any[]
	local shrinkable = {}

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if a == axis and string.find(chld.styl.sizing[a].mode, "^[Gg]") then
			table.insert(growable, chld)
			table.insert(shrinkable, chld)
		end
		if b == axis and string.find(chld.styl.sizing[b].mode, "^[Gg]") then
			chld.styl.size[b] = elem.styl.size[b] - p[b][1] - p[b][2]
		end
	end

	-- Grow & Shrink

	-- Remaining size

	---@type number
	local rem = elem.styl.size[a] - p[a][1] - p[a][2]
	for i = 1, #elem.chld do
		rem = rem - elem.chld[i].styl.size[a]
	end
	rem = rem - elem.styl.gap * (#elem.chld - 1)

	-- Grow along layout

	do
		local count = 0
		local tbl = growable
		while rem > 0 and tbl[1] do
			count = count + 1
			if count > 10 then break end

			---@type number
			local size_l = tbl[1].styl.size[a]
			---@type number
			local size_r = math.huge
			---@type number
			local add = rem

			for i = 1, #tbl do
				local chld = tbl[i]
				if chld.styl.size[a] < size_l then
					size_r = size_l
					size_l = chld.styl.size[a]
				end
				if chld.styl.size[a] > size_l then
					size_r = math.min(size_r, chld.styl.size[a])
					add = size_r - size_l
				end
			end

			---@type integer[]
			local removing = {}

			add = math.min(add, rem / #tbl)

			for i, chld in ipairs(tbl) do
				local prev = chld.styl.size[a]
				if chld.styl.size[a] == size_l then
					chld.styl.size[a] = chld.styl.size[a] + add
					if chld.styl.size[a] >= chld.styl.sizing[a].max then
						chld.styl.size[a] = chld.styl.sizing[a].max
						table.remove(tbl, i)
					end
					rem = rem - (chld.styl.size[a] - prev)
				end
			end
		end
	end

	-- Shrink along layout

	do
		local count = 0
		local tbl = shrinkable
		while rem < 0 and tbl[1] do
			count = count + 1
			if count > 10 then break end

			---@type number
			local size_l = tbl[1].styl.size[a]
			---@type number
			local size_r = math.huge
			---@type number
			local add = rem

			for i = 1, #tbl do
				local chld = tbl[i]
				if chld.styl.size[a] > size_l then
					size_r = size_l
					size_l = chld.styl.size[a]
				end
				if chld.styl.size[a] < size_l then
					size_r = math.min(size_r, chld.styl.size[a])
					add = size_r - size_l
				end
			end

			---@type integer[]
			local removing = {}

			add = math.min(add, rem / #tbl)

			for i, chld in ipairs(tbl) do
				local prev = chld.styl.size[a]
				if chld.styl.size[a] == size_l then
					chld.styl.size[a] = chld.styl.size[a] + add
					if chld.styl.size[a] <= chld.styl.sizing[a].min then
						chld.styl.size[a] = chld.styl.sizing[a].min
						table.remove(tbl, i)
					end
					rem = rem - (chld.styl.size[a] - prev)
				end
			end
		end
	end

	-- Recurse

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.grow(chld, axis)
	end
end

---@param elem FOXStencil.Element.Any
function lib.wrap(elem)
	if elem.type == "label" then
		elem.styl.size = client.getTextDimensions(elem.styl.text, elem.styl.size.x)
	elseif elem.type == "sprite" then
		local dim = elem.styl.texture --[[@as Texture]]:getDimensions()
		elem.styl.size.y = dim.y / dim.x * elem.styl.size.x
	elseif elem.chld then
		for i = 1, #elem.chld do
			local chld = elem.chld[i]
			lib.wrap(chld)
		end
	end
end

---Recursively calculates position of all children
---@param elem FOXStencil.Element.Any
function lib.position(elem)
	if not elem.chld then return end
	local a, b = rotate(elem.styl)
	local p = pad(elem.styl)

	-- Distribute

	local offset = p[a][1]
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.position(chld)

		chld.styl.pos[a] = chld.styl.pos[a] + offset
		offset = offset + chld.styl.size[a] + elem.styl.gap
		chld.styl.pos[b] = chld.styl.pos[b] + elem.styl.pad[b]
	end

	-- Align & Justify

	local rem = math.max(elem.styl.size[a] - offset + elem.styl.gap - p[a][2], 0)
	local inner = rem * elem.styl.justify
	local outer = rem * -(elem.styl.justify - 1)
	local gap = #elem.chld > 1 and inner / (#elem.chld - 1) or 0

	local y = math.max(elem.styl.size[b] - p[b][1] - p[b][2], 0)

	for i = 1, #elem.chld do
		local chld = elem.chld[i]

		chld.styl.pos[a] = chld.styl.pos[a] + gap * (i - 1) + (outer * elem.styl.align[a])
		chld.styl.pos[b] = chld.styl.pos[b] + ((y - chld.styl.size[b]) * elem.styl.align[b])
	end
end

local path = string.sub(..., 0, string.find(..., "[^/]+$") - 1) .. "element/"

---Creates ModelParts for this element and all of its children recursively
---@param elem FOXStencil.Element.Any
---@param part ModelPart
function lib.draw(elem, part)
	-- Create parent pivot

	elem.styl.part = models:newPart("elem")
		:moveTo(part)
		:pos(-elem.styl.pos:augmented(0.0625))

	-- Creates all children

	if elem.chld then
		for i = 1, #elem.chld do
			lib.draw(elem.chld[i], elem.styl.part)
		end
	end

	-- Creates the element

	require(path .. elem.type)(elem.styl.part, elem.styl)
end

return lib
