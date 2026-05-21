---@generic v
---@type table<type, fun(v: v): v>
local copy_type = {
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
return function(from, to)
	local diff = false

	for k, v in next, from do
		if to[k] ~= v then
			assert(copy_type[type(v)], "Unsupported type to copy " .. type(v))
			to[k] = copy_type[type(v)](v)
			diff = true
		end
	end

	return diff
end