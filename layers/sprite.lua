---@class FOXStencil.Sprite
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Sprite.Styles
local default = {
	---@type Texture
	texture = textures["FOXStencil_blank"],
	---@type Vector3|Vector4
	color = vec(1, 1, 1, 1),
	---@type boolean?
	grid = false,

	---@type Vector2
	pos = vec(0, 0),
	---@type Vector2
	size = vec(0, 0),

	---@type Vector2
	uv_pos = vec(0, 0),
	---@type Vector2
	uv_size = vec(1, 1),
}

---Redraws this label
---@param self FOXStencil.Sprite
local function draw(self)
	local styles = self.styles
	
	local dim = styles.texture:getDimensions()

	local visible = 0 < styles.size:length()
	local size = styles.grid and styles.size or styles.uv_size

	if visible then
		self.task
			:uv(styles.uv_pos / dim)
			:region(size * 1000)

			:pos(-styles.pos:augmented(0))
			:scale(styles.size:augmented())

			:dimensions(dim * 1000)
			:texture(styles.texture)
			:color(styles.color)
	end

	self.task:visible(visible)
end

---@generic v
---@type table<type, fun(v: v): v>
local copy = {
	Vector2 = function(v) return v:copy() end,
	Vector3 = function(v) return v:copy() end,
	Vector4 = function(v) return v:copy() end,
	Texture = function(v) return v end,
	boolean = function(v) return v end,
}

---Sets the given styles
---@param styles FOXStencil.Sprite.Styles
---@return self
function obj:setStyles(styles)
	local diff = false

	for k, v in next, styles do
		if self.styles[k] ~= v then
			self.styles[k] = copy[type(v)](v)
			diff = true
		end
	end

	if diff then
		draw(self)
	end

	return self
end

---Generates a sprite layer
---
---Call :setStyles() with a table to change the styles
---@param part ModelPart
---@return FOXStencil.Sprite
return function(part)
	---@class FOXStencil.Sprite
	local self = {
		task = part:newSprite("sprite-" .. math.random())
			:size(1, 1)
			:renderType("CUTOUT_EMISSIVE_SOLID"),
		styles = setmetatable({}, { __index = default }),
	}

	return setmetatable(self, obj)
end
