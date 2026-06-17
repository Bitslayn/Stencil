---@class FOXStencil.String
local lib = {}

---@class FOXStencil.String
---@field symbols string[]
local class = {
	__concat = function(a, b) return lib.of(lib.of(a):tostring() .. lib.of(b):tostring()) end,
	__eq = function(a, b) return lib.of(a):tostring() == lib.of(b):tostring() end,
	__type = "FOXStencil.String",
}
class.__index = class

---@param str string
---@return FOXStencil.String
function lib.of(str)
	if type(str) == "FOXStencil.String" then return str end

	local self = { symbols = {} }

	local i = 0
	for sym in str:gmatch("[\x00-\x7F\xC2-\xF4][\x80-\xBF]*") do
		i = i + 1
		self.symbols[i] = sym
	end

	return setmetatable(self, class)
end

---Creates and returns a new component of the substring
---@param i integer?
---@param j integer?
---@return FOXStencil.String
function class:sub(i, j)
	local l = #self.symbols

	i = i or 1
	j = j or -1

	-- Calculate negatives

	if i < 0 then i = i + l + 1 end
	if j < 0 then j = j + l + 1 end

	-- Clamp within range

	if i < 1 then i = 1 end
	if j > l then j = l end

	return lib.of(table.concat(self.symbols, "", i, j) or "")
end

function class:tostring()
	return table.concat(self.symbols)
end

class.__tostring = class.tostring

return lib
