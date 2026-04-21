---@class FOXStencil.Element.Debug
---@field line SpriteTask[]
---@field elem FOXStencil.Element
local obj = {}
obj.__index = obj

function obj:draw()
	local props = self.elem:getProps()
	local state = self.elem.state

	self.line[1]:scale(state.size.xy_)
	self.line[2]:rot(0, 180, -90):scale(state.size.yx_ --[[@as Vector3]])
end

---Creates debug lines
---@param elem FOXStencil.Element
---@return FOXStencil.Element.Debug
return function(elem)
	local self = setmetatable({
		line = {},
		elem = elem,
	}, obj)

	for i = 1, 2 do
		self.line[i] = elem.part:newSprite("debug-" .. i)
			:texture(textures["FOXStencil_blank"], 1, 1)
			:renderType("LINES")
			:color(vectors.hexToRGB("figura_blue"))
	end

	return self
end
