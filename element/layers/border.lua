---@class FOXStencil.Element.Border
---@field line SpriteTask[]
---@field elem FOXStencil.Element
local obj = {}
obj.__index = obj

local translate4 = matrices.translate4
local scale4 = matrices.scale4

local vec2 = vectors.vec2
local vec4 = vectors.vec4
local unpack = table.unpack
local unpack2 = vec2().unpack
local unpack4 = vec4().unpack
local tostring = tostring
local concat = table.concat

---Updates the current outline
function obj:draw()
	local props = self.elem.props

	local w_t, w_r, w_b, w_l = unpack4(props.border)
	local e_t, e_r, e_b, e_l = unpack4(props.border_extend)
	
	local w, h = unpack2(props.live_size + props.tex_extend.yx + props.tex_extend.wz --[[@as Vector2]])

	local mats = {
		-- Top
		translate4(w_l + e_l, w_t + e_t, -1)
		* scale4(w + w_l + w_r + e_l + e_r, w_t, 1),

		-- Right
		translate4(-w - e_r, e_t, -1)
		* scale4(w_r, h + e_t + e_b, 1),

		-- Bottom
		translate4(w_l + e_l, -h - e_b, -1)
		* scale4(w + w_l + w_r + e_l + e_r, w_b, 1),

		-- Left
		translate4(w_l + e_l, e_t, -1)
		* scale4(w_l, h + e_t + e_b, 1),
	}

	for i = 1, 4 do
		self[i]
			:matrix(translate4(props.tex_extend.w, props.tex_extend.x) * mats[i])
			:visible(props.border:length() > 0)

			-- TODO separate into run-on-call method
			:color(props.border_color)
	end
end

---Creates an empty outline that can be stylized later
---@param elem FOXStencil.Element
---@return FOXStencil.Element.Border
return function(elem)
	local self = setmetatable({
		elem = elem,
	}, obj)

	for i = 1, 4 do
		self[i] = elem.part:newSprite("outline-" .. i)
			:texture(textures["FOXStencil_blank"], 1, 1)
			:renderType("CUTOUT_EMISSIVE_SOLID")
	end

	return self
end
