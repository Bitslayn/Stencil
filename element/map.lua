---@class FOXMap
---@field package map table<any, integer>
---@field package val any[]
local map = {}

---Gets a key from its value
---@param v any
---@return integer
function map:getKey(v)
	return self.map[v]
end

---Gets a value from its key
---@param k integer
---@return any
function map:getVal(k)
	return self.val[k]
end

---Pushes this value to the top of the map
---
---Returns self for chaining
---@param v any
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
---@return any
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
---@param v any
---@return self
function map:insert(k, v)
	table.insert(self.val, k, v)
	return self:settle(k)
end

---Removes a value in the map at the given key, shifting existing keys backwards
---
---Returns the removed value
---@param k integer
---@return any
function map:remove(k)
	local v = table.remove(self.val, k)
	if not v then return end
	self.map[v] = nil
	self:settle(k)
	return v
end

function map:__index(k)
	return rawget(self.val, k) or map[k]
end

function map:__newindex(k, v)
	self.val[k] = v
	self.map[v] = k
end

function map:__len()
	return #self.val
end

function map:__pairs()
	return pairs(self.val)
end

function map:__ipairs()
	return ipairs(self.val)
end

---Creates an empty map
return function()
	return setmetatable({ map = {}, val = {} }, map)
end
