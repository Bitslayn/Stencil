---@class Stencil.Elements.Texture
---@field [number] SpriteTask
local obj = {}
obj.__index = obj

local newSprite = models.newSprite

local __index = figuraMetatables.SpriteTask.__index
local color = __index.color
local matrix = __index.matrix
local texture = __index.texture
local dimensions = __index.dimensions
local uv = __index.uv
local region = __index.region
local scale = __index.scale
local renderType = __index.renderType
local size = __index.size

local getDimensions = textures["FOXStencil_blank"].getDimensions

local vec2 = vectors.vec2

---Creates an empty texture that can be stylized later
---@param pivot ModelPart
---@return Stencil.Elements.Texture
local function new(pivot)
	local task = newSprite(pivot, "texture")
	texture(task, textures["FOXStencil_blank"], 1, 1)
	size(task, 1, 1)
	renderType(task, "CUTOUT_EMISSIVE_SOLID")

	return setmetatable({ task }, obj)
end

---Updates the current texture
---@param stat Stencil.State
function obj:update(stat)
	local tex = stat.texture

	local atlas
	local dim

	if tex.atlas then
		atlas = tex.atlas
		dim = getDimensions(atlas)
	else
		atlas = textures["FOXStencil_blank"]
		dim = vec2(1, 1)
	end

	local task = self[1]
	texture(task, atlas)
	dimensions(task, dim * vec2(1000, 1000))
	uv(task, tex.pos / dim)
	region(task, tex.size * 1000)
	scale(task, stat.size[1].val, stat.size[2].val)
	color(task, stat.color)
end

return new
