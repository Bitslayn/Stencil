--[[
Flashes an element white when it is being redrawn
]]

local enabled = false

if not enabled then return end

-- Inject into layout draw call

---@type FOXStencil.Render.Layout
local class = require("../layout/core/layout")

local draw = class.draw

-- Pulse animation

---@param part ModelPart
---@param pos Vector2
---@param size Vector2
local function pulse(part, pos, size)
	local old_sprite = part:getTask("pulse") --[[@as SpriteTask?]]

	local sprite = (old_sprite or part:newSprite("pulse"))
		:texture(textures["FOXStencil_blank"], 1, 1)
		:pos(pos.xy_)
		:scale(size.xy_)
		:color(1, 1, 1, 0.25)
		:renderType("SOLID")

	if old_sprite then return end

	local function tick()
		local a = math.max(sprite:getColor().a - 0.05, 0)
		sprite:color(1, 1, 1, a)
		if a ~= 0 then return end
		sprite:remove()
		events.tick:remove(tick)
	end
	events.tick:register(tick)
end

function class.draw(elem, ...)
	local part = elem.part
	
	local state = elem.state

	local pos = vec(0, 0)
	local size = state.size

	pulse(part, pos, size)
	draw(elem, ...)
end
