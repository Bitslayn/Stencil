local enabled = false

if not enabled then return end

-- Inject into element draw call

---@type FOXStencil.Element
local class = require("../element/element").class

local draw = class.draw

---@param name string
---@param part ModelPart
---@param color Vector3
---@param pos Vector2
---@param size Vector2
local function outline(name, part, color, pos, size)
	part:newSprite(name .. "-1")
		:texture(textures["FOXStencil_blank"], 1, 1)
		:pos(pos.xy_)
		:scale(size.xy_)
		:renderType("LINES")
		:color(color)

	part:newSprite(name .. "-2")
		:texture(textures["FOXStencil_blank"], 1, 1)
		:pos(pos.xy_)
		:rot(0, 180, -90)
		:scale(size.yx_ --[[@as Vector3]])
		:renderType("LINES")
		:color(color)
end

function class.draw(elem, ...)
	local part = elem.part

	local props = elem:getProps()
	local state = elem.state

	local pos = props.tex_extend.wx --[[@as Vector2]]
	local size = state.size.xy + props.tex_extend.wx + props.tex_extend.yz --[[@as Vector2]]

	outline("debug-bounds-outer", part, vectors.hexToRGB("figura_blue"), pos, size)

	if props.padding:length() > 0 then
		outline("debug-bounds-inner", part, vectors.hexToRGB("orange"),
			pos - props.padding.wx --[[@as Vector2]],
			size - props.padding.wx - props.padding.yz --[[@as Vector2]] --[[@as Vector2]]
		)
	end

	draw(elem, ...)
end
