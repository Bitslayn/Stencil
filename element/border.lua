---@class Stencil.Elements.Border
---@field [number] SpriteTask
---@field parn Stencil.Element
local obj = {}
obj.__index = obj

local newSprite = models.newSprite

local __index = figuraMetatables.SpriteTask.__index
local color = __index.color
local matrix = __index.matrix
local texture = __index.texture
local renderType = __index.renderType

local translate4 = matrices.translate4
local scale4 = matrices.scale4

local vec2 = vectors.vec2
local unpack = vec2().unpack

---Creates an empty outline that can be stylized later
---@param parn Stencil.Element
---@return Stencil.Elements.Border
local function new(parn)
	local self = setmetatable({ parn = parn }, obj)

	for i = 1, 4 do
		local task = newSprite(parn.part, "outline-" .. i)
		texture(task, textures["FOXStencil_blank"], 1, 1)
		renderType(task, "CUTOUT_EMISSIVE_SOLID")
		self[i] = task
	end

	return self
end

---Updates the current outline
function obj:update()
	local styl = self.parn.styl
	local stat = self.parn.stat
	local tex = styl.texture
	local s = styl.border[1].weight
	---@diagnostic disable-next-line: param-type-mismatch
	local w, h = unpack(stat.size + tex.extend.yx + tex.extend.wz)
	local d = self.parn.root.dept

	local hor = scale4(w + s * 2, s, 1)
	local ver = scale4(s, h, 1)

	local mats = {
		translate4(s, s, -d) * hor, -- Top
		translate4(-w, 0, -d) * ver, -- Right
		translate4(s, -h, -d) * hor, -- Bottom
		translate4(s, 0, -d) * ver, -- Left
	}

	for i = 1, 4 do
		local task = self[i]
		color(task, styl.border[1].color)
		matrix(task, translate4(tex.extend.w, tex.extend.x) * mats[i])
	end
end

return new
