---@class Stencil.Elements.Slice
---@field [number] SpriteTask[]
---@field parn Stencil.Element
local obj = {}
obj.__index = obj

local newSprite = models.newSprite

local __index = figuraMetatables.SpriteTask.__index
local color = __index.color
local matrix = __index.matrix
local texture = __index.texture
local dimensions = __index.dimensions
local uv = __index.uv
local pos = __index.pos
local region = __index.region
local scale = __index.scale
local renderType = __index.renderType
local size = __index.size

local getDimensions = textures:get("FOXStencil_blank").getDimensions

local vec2 = vectors.vec2
local unpack2 = vectors.vec2().unpack
local unpack4 = vectors.vec4().unpack

local min = math.min

---Updates the current slice
function obj:update()
	local styl = self.parn.styl
	local stat = self.parn.stat
	local tex = styl.texture
	local dim = getDimensions(tex.atlas)

	local t, r, b, l = unpack4(tex.slice)
	local atlas_w, atlas_h = unpack2(tex.size)
	---@diagnostic disable-next-line: param-type-mismatch
	local model_w, model_h = unpack2(stat.size + tex.extend.yx + tex.extend.wz)

	l = min(l, model_w / 2)
	r = min(r, model_w / 2)
	t = min(t, model_h / 2)
	b = min(b, model_h / 2)

	-- Row slices

	local e_atlas_x = { 0, l, atlas_w - r }
	local e_atlas_w = { l, atlas_w - l - r, r }
	local e_model_x = { 0, l, model_w - r }
	local e_model_w = { l, model_w - l - r, r }

	-- Column slices

	local e_atlas_y = { 0, t, atlas_h - b }
	local e_atlas_h = { t, atlas_h - t - b, b }
	local e_model_y = { 0, t, model_h - b }
	local e_model_h = { t, model_h - t - b, b }

	-- Create slices

	for y = 1, 3 do
		for x = 1, 3 do
			local task = self[y][x]
			texture(task, tex.atlas)
			dimensions(task, dim * vec2(1000, 1000))
			uv(task, (tex.pos + vec2(e_atlas_x[x], e_atlas_y[y])) / dim)
			region(task, e_atlas_w[x] * 1000, e_atlas_h[y] * 1000)
			pos(task, -e_model_x[x] + tex.extend.w, -e_model_y[y] + tex.extend.x)
			scale(task, e_model_w[x], e_model_h[y])
			color(task, styl.color)
		end
	end
end

---Creates an empty slice that can be stylized later
---@param parn Stencil.Element
---@return Stencil.Elements.Slice
return function(parn)
	local self = setmetatable({ parn = parn }, obj)

	for y = 1, 3 do
		self[y] = {}
		for x = 1, 3 do
			local task = newSprite(parn.part, "slice-" .. x .. y)
			texture(task, "FOXStencil_blank", 1, 1)
			size(task, 1, 1)
			renderType(task, "CUTOUT_EMISSIVE_SOLID")
			self[y][x] = task
		end
	end

	return self
end
