local lib = {}

---@generic v
---@param v v
---@param msg string?
---@return v
local function assert(v, msg)
	return v or error(msg, 4)
end

---@type table<string, table<type, true>>
local overloads = {
	color = setmetatable({ Vector3 = true, Vector4 = true }, { __type = "Vector3|Vector4" }),
}

---@generic v
---@type table<type, fun(v: v): v>
local types = {
	Vector2 = function(v) return v:copy() end,
	Vector3 = function(v) return v:copy() end,
	Vector4 = function(v) return v:copy() end,
	Texture = function(v) return v end,
	number = function(v) return v end,
	boolean = function(v) return v end,
	string = function(v) return v end,
}

---@param from table
---@param to table
---@return boolean
function lib.copy(from, to)
	local diff = false

	for k, v in next, from do
		if to[k] ~= v then
			local t1 = type(to[k])
			local t2 = type(v)
			local t3 = overloads[k] and type(overloads[k])

			if not (overloads[k] and overloads[k][t2]) then
				assert(t1 == t2, string.format("Unexpected type to set on key '%s', %s expected but found %s", k, t3 or t1, t2))
				assert(types[t2], string.format("Unsupported type %s to copy", t2))
			end

			to[k] = types[t2](v)
			diff = true
		end
	end

	return diff
end

return lib
