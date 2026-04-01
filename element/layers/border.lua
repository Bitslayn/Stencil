---@class Stencil.Elements.Border
---@field line SpriteTask[]
---@field id string
---@field parn Stencil.Element
local obj = {}
obj.__index = obj

local translate4 = matrices.translate4
local scale4 = matrices.scale4

local vec2 = vectors.vec2
local vec4 = vectors.vec4
local unpack2 = vec2().unpack
local unpack4 = vec4().unpack
local tostring = tostring
local concat = table.concat

---Updates the current outline
function obj:draw()
	local styl = self.parn.styl
	local stat = self.parn.stat
	local tex = styl.texture

	local id = concat({
		concat({ unpack2(stat.pos) }),
		concat({ unpack2(stat.size) }),
		concat({ unpack4(tex.extend) }),
		styl.border[1].weight,
	})
	if self.id == id then return end
	self.id = id

	local s = styl.border[1].weight
	local w, h = unpack2(stat.size + tex.extend.yx --[[@as Vector2]] + tex.extend.wz --[[@as Vector2]])

	local hor = scale4(w + s * 2, s, 1)
	local ver = scale4(s, h, 1)

	local mats = {
		translate4(s, s, -2) * hor, -- Top
		translate4(-w, 0, -2) * ver, -- Right
		translate4(s, -h, -2) * hor, -- Bottom
		translate4(s, 0, -2) * ver, -- Left
	}

	for i = 1, 4 do
		local task = self[i]
			:matrix(translate4(tex.extend.w, tex.extend.x) * mats[i])

			-- TODO separate into run-on-call method
			:color(styl.border[1].color)
	end
end

---Creates an empty outline that can be stylized later
---@param parn Stencil.Element
---@return Stencil.Elements.Border
return function(parn)
	local self = setmetatable({
		parn = parn,
	}, obj)

	for i = 1, 4 do
		self[i] = parn.part:newSprite("outline-" .. i)
			:texture(textures["FOXStencil_blank"], 1, 1)
			:renderType("CUTOUT_EMISSIVE_SOLID")
	end

	return self
end
