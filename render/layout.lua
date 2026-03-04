---@class FOXStencil.Render.Layout
local lib = {}

--[[
All child element positions are relative to their parent
The parent element size depends on its children
Calculate width first before wrapping text and then calculate height
]]

---@param elem FOXStencil.Element.Any
---@return integer, integer
local function rotate(elem)
	local dir = string.find(elem.styl.dir, "^[Vvy]") and 2 or 1
	local a = dir
	local b = dir % 2 + 1

	return a, b
end

---Recursively calculates size of all children
---@param elem FOXStencil.Element.Any
---@param axis integer
function lib.size(elem, axis)
	if not elem.chld then return end
	local a, b = rotate(elem)

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

---Recursively grows child elements
---@param elem FOXStencil.Element.Any
---@param axis integer
function lib.grow(elem, axis)
	if not elem.chld then return end
	local a, b = rotate(elem)

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
			if b == 1 then
				chld.styl.size.x = elem.styl.size.x - elem.styl.pad[2] - elem.styl.pad[4]
			else
				chld.styl.size.y = elem.styl.size.y - elem.styl.pad[1] - elem.styl.pad[3]
			end
		end
	end

	-- Grow & Shrink

	-- Remaining size

	---@type number
	local rem = elem.styl.size[a] - elem.styl.pad[a] * 2
	for i = 1, #elem.chld do
		rem = rem - elem.chld[i].styl.size[a]
	end
	rem = rem - elem.styl.gap * (#elem.chld - 1)

	-- Grow along layout

	while rem > 0 and growable[1] do
		---@type number
		local size_l = growable[1].styl.size[a]
		---@type number
		local size_r = math.huge
		---@type number
		local add = rem

		for i = 1, #growable do
			local chld = growable[i]
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

		add = math.min(add, rem / #growable)

		for i = 1, #growable do
			local chld = growable[i]
			local prev = chld.styl.size[a]
			if chld.styl.size[a] == size_l then
				chld.styl.size[a] = chld.styl.size[a] + add
				if chld.styl.size[a] >= chld.styl.sizing[a].max then
					chld.styl.size[a] = chld.styl.sizing[a].max
					table.insert(removing, i)
				end
				rem = rem - (chld.styl.size[a] - prev)
			end
		end

		for i = 1, #removing do
			table.remove(growable, removing[i])
		end
	end

	-- Shrink along layout

	while rem < 0 and shrinkable[1] do
		---@type number
		local size_l = shrinkable[1].styl.size[a]
		---@type number
		local size_r = math.huge
		---@type number
		local add = rem

		for i = 1, #shrinkable do
			local chld = shrinkable[i]
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

		add = math.min(add, rem / #shrinkable)

		for i = 1, #shrinkable do
			local chld = shrinkable[i]
			local prev = chld.styl.size[a]
			if chld.styl.size[a] == size_l then
				chld.styl.size[a] = chld.styl.size[a] + add
				if chld.styl.size[a] <= chld.styl.sizing[a].min then
					chld.styl.size[a] = chld.styl.sizing[a].min
					table.insert(removing, i)
				end
				rem = rem - (chld.styl.size[a] - prev)
			end
		end

		for i = 1, #removing do
			table.remove(shrinkable, removing[i])
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
	if elem.type == "text" then
		elem.styl.size = client.getTextDimensions(elem.styl.text, elem.styl.size.x)
	else
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
	local a, b = rotate(elem)

	local pad = {
		{ elem.styl.pad[4], elem.styl.pad[2] }, -- x: left, right
		{ elem.styl.pad[1], elem.styl.pad[3] }, -- y: top, bottom
	}

	-- Distribute

	local offset = pad[a][1]
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.position(chld)

		chld.styl.pos[a] = chld.styl.pos[a] + offset
		offset = offset + chld.styl.size[a] + elem.styl.gap
		chld.styl.pos[b] = chld.styl.pos[b] + elem.styl.pad[b]
	end

	-- Align & Justify

	local rem = math.max(elem.styl.size[a] - offset + elem.styl.gap - pad[a][2], 0)
	local inner = rem * elem.styl.justify
	local outer = rem * -(elem.styl.justify - 1)
	local gap = #elem.chld > 1 and inner / (#elem.chld - 1) or 0

	local y = math.max(elem.styl.size[b] - pad[b][1] - pad[b][2], 0)

	for i = 1, #elem.chld do
		local chld = elem.chld[i]

		chld.styl.pos[a] = chld.styl.pos[a] + gap * (i - 1) + (outer * elem.styl.align[a])
		chld.styl.pos[b] = chld.styl.pos[b] + ((y - chld.styl.size[b]) * elem.styl.align[b])
	end
end

---Creates ModelParts for this element and all of its children recursively
---@param elem FOXStencil.Element.Any
---@param part ModelPart
function lib.draw(elem, part)
	-- Create parent pivot

	local parent = models:newPart("elem")
		:moveTo(part)
		:pos(-elem.styl.pos:augmented(0.0625))

	-- Creates all children

	if elem.chld then
		for i = 1, #elem.chld do
			lib.draw(elem.chld[i], parent)
		end
	end

	-- Creates the element

	require("../element/" .. elem.type)(parent, elem.styl)
end

return lib
