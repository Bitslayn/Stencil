---@class FOXStencil.Element.Slice
---@field cell SpriteTask[][]
---@field elem FOXStencil.Element
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
	local props = self.elem.props
	local dim = getDimensions(props.tex)

	local t, r, b, l = unpack4(props.tex_slice)
	local atlas_w, atlas_h = unpack2(props.tex_size)
	local model_w, model_h = unpack2(props.live_size + props.tex_extend.yx + props.tex_extend.wz --[[@as Vector2]])
	local e_x = props.tex_extend.x
	local e_w = props.tex_extend.w

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
				:uv((props.tex_pos + vec2(e_atlas_x[x], e_atlas_y[y])) / dim)
				:region(e_atlas_w[x] * 1000, e_atlas_h[y] * 1000)
				:pos(-e_model_x[x] + props.tex_extend.w, -e_model_y[y] + props.tex_extend.x)
				:scale(e_model_w[x], e_model_h[y])
				:visible(0 < e_atlas_w[x] and 0 < e_atlas_h[y])

			-- TODO separate into run-on-call methods
				:texture(props.tex)
				:dimensions(dim * 1000)

				:color(props.tex_color)
		end
	end
end

---Creates an empty slice that can be stylized later
---@param elem FOXStencil.Element
---@return FOXStencil.Element.Slice
return function(elem)
	local self = setmetatable({
		cell = {},
		elem = elem,
	}, obj)

	for y = 1, 3 do
		self.cell[y] = {}
		for x = 1, 3 do
			self.cell[y][x] = elem.part:newSprite("slice-" .. x .. y)
				:texture(textures["FOXStencil_blank"], 1, 1)
				:size(1, 1)
				:renderType("CUTOUT_EMISSIVE_SOLID")
		end
	end

	return self
end
