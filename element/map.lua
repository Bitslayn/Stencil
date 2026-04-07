--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Map v1.0
]]

---@class FOXMap<K, V>: { [K]: V }
---@field package val table<K, V>
---@field package map table<V, K>
local map = {}

---Creates an empty map
---@return FOXMap
local function new()
	return setmetatable({ val = {}, map = {} }, map)
end

---Gets a key from its value
---@param v V
---@return K?
function map:getKey(v)
	return self.map[v]
end

---Gets a value from its key
---@param k K
---@return V?
function map:getVal(k)
	return self.val[k]
end

---Pushes this value to the top of the map
---
---Returns self for chaining
---@param v V
---@return self
function map:push(v)
	local k = #self.val + 1
	self.val[k] = v
	self.map[v] = k
	return self
end

---Pops the value at the top of the map
---
---Returns the popped value
---@return V?
function map:pop()
	local k = #self.val
	local v = self.val[k]
	self.val[k] = nil
	self.map[v] = nil
	return v
end

---Settles this map
---
---Run this whenever a random key is removed from the table
---
---Returns self for chaining
---@param i integer?
---@param j integer?
---@return self
function map:settle(i, j)
	for k = i or 1, j or #self.val do
		local v = self.val[k]
		self.map[v] = k
	end
	return self
end

---Inserts a value in the map at the given key, shifting existing keys forward
---
---Returns self for chaining
---@param k integer
---@param v V
---@return self
function map:insert(k, v)
	table.insert(self.val, k, v)
	return self:settle(k)
end

---Removes a value in the map at the given key, shifting existing keys backwards
---
---Returns the removed value
---@param k integer
---@return V?
function map:remove(k)
	local v = table.remove(self.val, k)
	if not v then return end
	self.map[v] = nil
	self:settle(k)
	return v
end

---@package
function map:__index(k)
	return rawget(self.val, k) or map[k]
end

---@package
function map:__newindex(k, v)
	self.val[k] = v
	self.map[v] = k
end

---@package
function map:__len()
	return #self.val
end

---@package
function map:__pairs()
	return pairs(self.val)
end

---@package
function map:__ipairs()
	return ipairs(self.val)
end

return new
