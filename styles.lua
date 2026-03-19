local stencil = {}

---@alias Stencil.Mode
---| "fit"
---| "FIT"
---| "grow"
---| "GROW"

---@alias Stencil.Direction
---| "x"
---| "hor"
---| "horizontal"
---| "HORIZONTAL"
---| "y"
---| "ver"
---| "vertical"
---| "VERTICAL"

---@class Stencil.Style
---@field pos Stencil.Styles.Pos?
---@field size Stencil.Styles.Size?
---@field scale Stencil.Styles.Scale?
---@field margin Stencil.Styles.Margin?
---@field border Stencil.Styles.Border?
---@field dir Stencil.Styles.Dir?
---@field padding Stencil.Styles.Padding?
---@field spacing Stencil.Styles.Spacing?
---@field align Stencil.Styles.Align?
---@field color Stencil.Styles.Color?
---@field label Stencil.Styles.Label?
---@field image Stencil.Styles.Texture?

---@alias Stencil.Styles.Pos Vector2
---@alias Stencil.Styles.Size Vector2
---@alias Stencil.Styles.Scale number|Vector2
---@alias Stencil.Styles.Margin number|Vector2|Vector3|Vector4
---@alias Stencil.Styles.Border number|Vector2|Vector3|Vector4
---@alias Stencil.Styles.Dir Stencil.Direction
---@alias Stencil.Styles.Padding number|Vector2|Vector3|Vector4
---@alias Stencil.Styles.Spacing number
---@alias Stencil.Styles.Align number|Vector2
---@alias Stencil.Styles.Color Vector3|Vector4
---@alias Stencil.Styles.Label string
---@alias Stencil.Styles.Texture Texture

---Merges tables and does surface level scrubbing
---@param a table
---@param b table
---@return table
local function merge(a, b)
	if type(b) ~= "table" then return a end
	for k, v in next, b do
		if type(a[k]) == type(v) then
			a[k] = v
		end
	end
	return a
end

---@param x number|{mode: Stencil.Mode, min: number, max: number}?
---@param y number|{mode: Stencil.Mode, min: number, max: number}?
---@return Stencil.Styles.Size
function stencil.size(x, y)
	local vars = { x, y }

	for i = 1, #vars do
		-- Accepts numbers as default weight value

		local v = vars[i]
		if type(v) == "number" then
			v = {
				min = v,
			}
		end

		-- Merge function will throw away non-tables and illegal arguments

		vars[i] = merge({
			mode = "FIT",
			min = 0,
			max = math.huge,
		}, v)
	end

	---@diagnostic disable-next-line: return-type-mismatch
	return vars
end

---@param t number|{weight: number, color: Vector4}
---@param r number|{weight: number, color: Vector4}
---@param b number|{weight: number, color: Vector4}
---@param l number|{weight: number, color: Vector4}
---@return Stencil.Styles.Border
function stencil.border(t, r, b, l)
	local vars = { t, r, b, l }

	for i = 1, #vars do
		-- Accepts numbers as default weight value

		local v = vars[i]
		if type(v) == "number" then
			v = {
				weight = v,
			}
		end

		-- Merge function will throw away non-tables and illegal arguments

		vars[i] = merge({
			weight = 0,
			color = vec(0, 0, 0, 1),
		}, v)
	end

	---@diagnostic disable-next-line: return-type-mismatch
	return vars
end

---@param t {text: string, color: Vector4, align: "LEFT"|"CENTER"|"RIGHT"}
---@return Stencil.Styles.Label
function stencil.label(t)
	-- Merge function will throw away non-tables and illegal arguments

	---@diagnostic disable-next-line: return-type-mismatch
	return merge({
		text = "",
		color = vec(0, 0, 0, 1),
		align = "LEFT",
	}, t)
end

---@param t {atlas: Texture, pos: Vector2, size: Vector2, slice: Vector4, extend: Vector4}
---@return Stencil.Styles.Texture
function stencil.texture(t)
	-- Merge function will throw away non-tables and illegal arguments

	---@diagnostic disable-next-line: return-type-mismatch
	return merge({
		atlas = textures[""],
		pos = vec(0, 0),
		size = vec(0, 0),
		slice = vec(0, 0, 0, 0),
		extend = vec(0, 0, 0, 0),
	}, t)
end

---@param t {mode: string, amount: number}
---@return Stencil.Styles.Spacing
function stencil.spacing(t)
	-- Merge function will throw away non-tables and illegal arguments

	---@diagnostic disable-next-line: return-type-mismatch
	return merge({
		mode = "NORMAL",
		amount = 0,
	}, t)
end

---Creates a new element
---@generic self
---@param self self
---@param id string
---@param style Stencil.Style?
---@return self
function stencil:newElement(id, style) return self end

---Sets this element's style
---@generic self
---@param self self
---@param style Stencil.Style?
---@return self
function stencil:setStyle(style) return self end

---Sets a function to run when this element is hovered
---@generic self
---@param self self
---@param func fun(element: self)?
---@return self
function stencil:setOnHover(func) return self end

---Sets a function to run when this element is clicked
---@generic self
---@param self self
---@param func fun(element: self)?
---@return self
function stencil:setOnClick(func) return self end

---Sets a function to run when this element is scrolled
---@generic self
---@param self self
---@param func fun(element: self)?
---@return self
function stencil:setOnScroll(func) return self end

stencil:newElement("simple", {
	-- Element alignment

	pos = vec(0, 0),
	size = vec(0, 0),
	scale = 1,
	margin = 1,
	border = 1,

	-- Child alignment

	dir = "y",
	padding = 1,
	spacing = 1,
	align = 0.5,

	-- Element appearance

	color = vec(0, 0, 0, 0),
	label = ":3",
	texture = textures[""],
})

stencil:newElement("advanced", {
	-- Element alignment

	pos = vec(0, 0),
	size = stencil.size(10, { mode = "GROW" }),
	scale = vec(1, 1),
	margin = vec(0, 0, 0, 0),
	border = stencil.border({ weight = 1, color = vec(1, 1, 1, 1) }, 0, 0, 0),

	-- Child alignment

	dir = "y",
	padding = vec(0, 0, 0, 0),
	spacing = stencil.spacing({ mode = "PERCENT", amount = 1 }),
	align = vec(0, 0),

	-- Element appearance

	color = vec(0, 0, 0, 0),
	label = stencil.label({ text = ":3", color = vec(0, 0, 0, 1) }),
	texture = stencil.texture({ atlas = textures[""], size = vec(16, 16), slice = vec(2, 2, 2, 2) }),
})
