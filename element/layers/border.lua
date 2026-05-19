---@class FOXStencil.Element.Border
---@field line SpriteTask[]
---@field elem FOXStencil.Element
local obj = {}
obj.__index = obj

---Updates the current outline
function obj:draw()
	local props = self.elem.props
	local state = self.elem.state

	local w_t, w_r, w_b, w_l = props.border:unpack()
	local e_t, e_r, e_b, e_l = props.border_extend:unpack()
	
	local w, h = (state.size + props.tex_extend.yx + props.tex_extend.wz --[[@as Vector2]]):unpack()

	local mats = {
		-- Top
		matrices.translate4(w_l + e_l, w_t + e_t, -1)
		* matrices.scale4(w + w_l + w_r + e_l + e_r, w_t, 1),

		-- Right
		matrices.translate4(-w - e_r, e_t, -1)
		* matrices.scale4(w_r, h + e_t + e_b, 1),

		-- Bottom
		matrices.translate4(w_l + e_l, -h - e_b, -1)
		* matrices.scale4(w + w_l + w_r + e_l + e_r, w_b, 1),

		-- Left
		matrices.translate4(w_l + e_l, e_t, -1)
		* matrices.scale4(w_l, h + e_t + e_b, 1),
	}

	for i = 1, 4 do
		self.line[i]
			:matrix(matrices.translate4(props.tex_extend.w, props.tex_extend.x) * mats[i])
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
		line = {},
		elem = elem,
	}, obj)

	for i = 1, 4 do
		self.line[i] = elem.part:newSprite("outline-" .. i)
			:texture(textures["FOXStencil_blank"], 1, 1)
			:renderType("CUTOUT_EMISSIVE_SOLID")
	end

	return self
end
