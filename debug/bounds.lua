--[[
Adds debug outlines to visualize element bounds

	Blue: True bounds that register mouse clicks and hover events
	Orange: Inner padding for child elements
]]

local enabled = false

if not enabled then return end

textures:newTexture("FOXStencil_blank", 1, 1):pixel(0, 0, vec(1, 1, 1))

-- Inject into layout draw call

local class = require("../layout/core/layout") --[[@as FOXStencil.Core.Layout]]

local draw = class.draw

-- Draw outlines

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
	draw(elem, ...)

	local part = elem.part

	local props = elem.props
	local state = elem.state

	local pos = vec(0, 0)
	local size = state.size

	outline("debug-bounds-outer", part, vectors.hexToRGB("figura_blue"), pos, size)

	if props.padding:length() > 0 then
		outline("debug-bounds-inner", part, vectors.hexToRGB("orange"),
			pos - props.padding.wx --[[@as Vector2]],
			size - props.padding.wx - props.padding.yz --[[@as Vector2]]
		)
	end
end
