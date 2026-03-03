---@class FOXStencil.Render.Layout
local lib = {}

--[[
All child element positions are relative to their parent
The parent element size depends on its children
Calculate width first before wrapping text and then calculate height
]]

---Recursively calculates size of all children
---@param elem FOXStencil.Element.Any
function lib.size(elem)
	-- Axis indices

	local dir = string.find(elem.styl.dir, "^[Vvy]") and 2 or 1
	local a = dir
	local b = dir % 2 + 1

	-- Fit children

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.size(chld)

		elem.styl.size[a] = elem.styl.size[a] + chld.styl.size[a]
		elem.styl.size[b] = math.max(elem.styl.size[b], chld.styl.size[b])
	end

	-- Gap & Padding

	elem.styl.size[a] = elem.styl.size[a] + elem.styl.gap * (#elem.chld - 1)
	elem.styl.size = elem.styl.size + elem.styl.pad * 2
end

---Recursively grows child elements
---@param elem FOXStencil.Element.Any
function lib.grow(elem)
	-- Axis indices

	local dir = string.find(elem.styl.dir, "^[Vvy]") and 2 or 1
	local a = dir
	local b = dir % 2 + 1

	-- Find growable

	---@type FOXStencil.Element.Any[]
	local growable = {}

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		local mode = chld.styl.mode
		if string.find(mode[a], "^[Gg]") then
			table.insert(growable, chld)
		end
		if string.find(mode[b], "^[Gg]") then
			chld.styl.size[b] = elem.styl.size[b] - elem.styl.pad[b] * 2
		end
	end

	-- Grow

	if growable[1] then
		-- Remaining size

		---@type number
		local rem = elem.styl.size[a] - elem.styl.pad[a] * 2
		for i = 1, #elem.chld do
			rem = rem - elem.chld[i].styl.size[a]
		end
		rem = rem - elem.styl.gap * (#elem.chld - 1)

		-- Grow along layout

		for _ = 1, 10 do
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

			add = math.min(add, rem / #growable)

			for i = 1, #growable do
				local chld = growable[i]
				if chld.styl.size[a] == size_l then
					chld.styl.size[a] = chld.styl.size[a] + add
					rem = rem - add
				end
			end

			if rem == 0 then break end
		end
	end

	-- Recurse

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.grow(chld)
	end
end

---Recursively calculates position of all children
---@param elem FOXStencil.Element.Any
function lib.position(elem)
	-- Axis indices

	local dir = string.find(elem.styl.dir, "^[Vvy]") and 2 or 1
	local a = dir
	local b = dir % 2 + 1

	-- Align children

	local offset = elem.styl.pad[a]
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.position(chld)

		chld.styl.pos[a] = chld.styl.pos[a] + offset
		offset = offset + chld.styl.size[a] + elem.styl.gap
		chld.styl.pos[b] = chld.styl.pos[b] + elem.styl.pad[b]
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

	for i = 1, #elem.chld do
		lib.draw(elem.chld[i], parent)
	end

	-- Creates the element

	require("../element/" .. elem.type)(parent, elem.styl)
end

return lib
