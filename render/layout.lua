---@class FOXStencil.Render.Layout
local lib = {}

--[[ TODO
Optimize rendering (Allow for reusing layouts):
	Separate styles and state to avoid mutation and allow safe redraw
	Split draw into create and transform steps
	Split elements into separate files again, but drawing elements can draw from any or all element definitions in a flat way
Comment ALL math
Add scale
Add margins
Add text customizations
Figure out widgets
]]

---@param stat Stencil.State
---@return integer, integer
local function rotate(stat)
	local dir = string.find(stat.dir, "^[Vvy]") and 2 or 1
	local a = dir
	local b = dir % 2 + 1

	return a, b
end

---@param stat Stencil.State
---@return [{[1]: number, [2]: number}, {[1]: number, [2]: number}]
local function pad(stat)
	return {
		{ stat.padding[4], stat.padding[2] }, -- x: left, right
		{ stat.padding[1], stat.padding[3] }, -- y: top, bottom
	}
end


---Deep copies the given table, including metatables
---@param t table
---@return table
local function copy(t)
	local c = {}
	for k, v in next, t do
		if type(v) == "table" then
			rawset(c, k, copy(v))
		else
			rawset(c, k, v)
		end
	end
	local m = getmetatable(t)
	return setmetatable(c, type(m) == "table" and m or nil)
end

---@param elem Stencil.Element
function lib.restore(elem)
	elem.stat = copy(elem.styl)

	for i = 1, #elem.chld do
		lib.restore(elem.chld[i])
	end
end

---Recursively calculates size of all children
---@param elem Stencil.Element
---@param axis integer
function lib.size(elem, axis)
	if not elem.chld[1] then return end
	local a, b = rotate(elem.stat)
	local p = pad(elem.stat)

	-- Fit children

	local size = 0
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.size(chld, axis)

		if a == axis then
			size = size + chld.stat.size[a].val
			elem.stat.size[a].min = elem.stat.size[a].min + chld.stat.size[a].min
		end
		if b == axis then
			elem.stat.size[b].val = math.max(elem.stat.size[b].val, chld.stat.size[b].val)
			elem.stat.size[b].min = math.max(elem.stat.size[b].min, chld.stat.size[b].min)
		end
	end
	elem.stat.size[a].val = math.max(elem.stat.size[a].val, size)

	-- Gap & Padding

	if a == axis then
		elem.stat.size[axis].val = elem.stat.size[axis].val + elem.stat.gap * (#elem.chld - 1)
	end

	elem.stat.size[axis].val = elem.stat.size[axis].val + p[axis][1] + p[axis][2]
end

---Recursively grows child elements
---@param elem Stencil.Element
---@param axis integer
function lib.grow(elem, axis)
	if not elem.chld[1] then return end
	local a, b = rotate(elem.stat)
	local p = pad(elem.stat)

	-- Find flexible

	---@type Stencil.Element[]
	local flexible = {}

	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		if a == axis and string.find(chld.stat.size[a].mode, "^[Gg]") then
			table.insert(flexible, chld)
		end
		if b == axis and string.find(chld.stat.size[b].mode, "^[Gg]") then
			chld.stat.size[axis].val = elem.stat.size[axis].val - p[axis][1] - p[axis][2]
		end
	end

	-- Calculate remaining size

	local rem = elem.stat.size[a].val - p[a][1] - p[a][2]
	for i = 1, #elem.chld do
		rem = rem - elem.chld[i].stat.size[a].val
	end
	rem = rem - elem.stat.gap * (#elem.chld - 1)

	-- Grow and shrink along layout

	while rem - rem % .25 ~= 0 and flexible[1] do
		local sign = math.sign(rem)
		local size_l = flexible[1].stat.size[a].val
		local size_r = math.huge
		local add = rem

		-- Find largest children

		for i = 1, #flexible do
			local chld = flexible[i]
			local size = chld.stat.size[a].val
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
			local size = chld.stat.size[a].val
			local prev = size
			if size == size_l then
				size = size + add
				local sizing = chld.stat.size[a]
				if size <= sizing.min or size >= sizing.max then
					size = math.clamp(size, sizing.min, sizing.max)
					table.remove(flexible, i)
				end
				rem = rem - (size - prev)
				chld.stat.size[a].val = size
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
	if not elem.chld[1] then return end
	local a, b = rotate(elem.stat)
	local p = pad(elem.stat)

	-- Distribute

	local offset = p[a][1]
	for i = 1, #elem.chld do
		local chld = elem.chld[i]
		lib.position(chld)

		chld.stat.pos[a] = chld.stat.pos[a] + offset
		offset = offset + chld.stat.size[a].val + elem.stat.gap
		chld.stat.pos[b] = chld.stat.pos[b] + p[b][1]
	end

	-- Align & Justify

	local rem = math.max(elem.stat.size[a].val - offset + elem.stat.gap - p[a][2], 0)
	local inner = rem * elem.stat.justify
	local outer = rem * -(elem.stat.justify - 1)
	local gap = #elem.chld > 1 and inner / (#elem.chld - 1) or 0

	local y = math.max(elem.stat.size[b].val - p[b][1] - p[b][2], 0)

	for i = 1, #elem.chld do
		local chld = elem.chld[i]

		chld.stat.pos[a] = chld.stat.pos[a] + gap * (i - 1) + (outer * elem.stat.align[a])
		chld.stat.pos[b] = chld.stat.pos[b] + ((y - chld.stat.size[b].val) * elem.stat.align[b])
	end
end

---Creates ModelParts for this element and all of its children recursively
---@param elem Stencil.Element
function lib.draw(elem)
	if elem.chld then
		for i = 1, #elem.chld do
			lib.draw(elem.chld[i])
		end
	end
	
	if not elem.elem then return end
	
	elem.elem.border:update(elem.stat)
	-- elem.elem.label:update(elem.stat)
	elem.elem.slice:update(elem.stat)
end

-- ---Recursively gets the element hovered over
-- ---@param elem FOXStencil.Element.Any
-- ---@param pos Vector2
-- ---@return FOXStencil.Element.Any?
-- function lib.hover(elem, pos)
-- 	local stat = elem.stat
-- 	if not (stat.pos <= pos and pos <= stat.pos + stat.size) then return end

-- 	-- Find hovered child element

-- 	if elem.chld then
-- 		for i = #elem.chld, 1, -1 do
-- 			local res = lib.hover(elem.chld[i], pos - stat.pos)
-- 			if res then return res end
-- 		end
-- 	end

-- 	-- Fall back to returning current hovered element

-- 	return elem
-- end

return lib
