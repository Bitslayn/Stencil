---@class Stencil.Elements.Slice
---@field cell SpriteTask[][]
---@field id string
---@field parn Stencil.Element
local obj = {}
obj.__index = obj

local getDimensions = textures["FOXStencil_blank"].getDimensions

local vec2 = vectors.vec2
local vec3 = vectors.vec3
local vec4 = vectors.vec4
local unpack2 = vec2().unpack
local unpack4 = vec4().unpack
local tostring = tostring
local concat = table.concat

---Updates the current slice
function obj:draw()
	local styl = self.parn.styl
	local stat = self.parn.stat
	local tex = styl.texture

	local id = concat({
		concat({ unpack2(stat.pos) }),
		concat({ unpack2(stat.size) }),
		concat({ unpack2(tex.pos) }),
		concat({ unpack2(tex.size) }),
		concat({ unpack4(tex.slice) }),
		concat({ unpack4(tex.extend) }),
	})
	if self.id == id then return end
	self.id = id

	local dim = getDimensions(tex.atlas)

	local t, r, b, l = unpack4(tex.slice)
	local atlas_w, atlas_h = unpack2(tex.size)
	local model_w, model_h = unpack2(stat.size + tex.extend.yx --[[@as Vector2]] + tex.extend.wz --[[@as Vector2]])
	local e_x = tex.extend.x
	local e_w = tex.extend.w

	l = math.min(l, model_w / 2)
	r = math.min(r, model_w / 2)
	t = math.min(t, model_h / 2)
	b = math.min(b, model_h / 2)

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

	-- Update slices

	for y = 1, 3 do
		for x = 1, 3 do
			self.cell[y][x]
			-- TODO (maybe) separate uv and region into run-on-call methods
				:uv((tex.pos + vec2(e_atlas_x[x], e_atlas_y[y])) / dim)
				:region(e_atlas_w[x] * 1000, e_atlas_h[y] * 1000)
				:pos(-e_model_x[x] + tex.extend.w, -e_model_y[y] + tex.extend.x)
				:scale(e_model_w[x], e_model_h[y])
				:visible(0 < e_atlas_w[x] and 0 < e_atlas_h[y])

			-- TODO separate into run-on-call methods
				:texture(tex.atlas)
				:dimensions(dim * 1000)

				:color(styl.color)
		end
	end
end

---Creates an empty slice that can be stylized later
---@param parn Stencil.Element
---@return Stencil.Elements.Slice
return function(parn)
	local self = setmetatable({
		cell = {},
		id = "",
		parn = parn,
	}, obj)

	for y = 1, 3 do
		self.cell[y] = {}
		for x = 1, 3 do
			self.cell[y][x] = parn.part:newSprite("slice-" .. x .. y)
				:texture(textures["FOXStencil_blank"], 1, 1)
				:size(1, 1)
				:renderType("CUTOUT_EMISSIVE_SOLID")
		end
	end

	return self
end
