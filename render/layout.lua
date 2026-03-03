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

function lib.grow(elem)

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
