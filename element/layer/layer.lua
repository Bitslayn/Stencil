local subpath = ... .. "/presets"

---@param super FOXStencil.Element
return function(super)
	---@class FOXStencil.Layer
	local class = {}
	---@package
	class.__index = class

	local presets = listFiles(subpath)
	for i = 1, #presets do
		pcall(require(presets[i]), class, super)
	end

	---@param elem FOXStencil.Element
	---@return FOXStencil.Layer
	function class.new(elem)
		---@class FOXStencil.Layer
		local self = setmetatable({
			id = client.intUUIDToString(client.generateUUID()),
			elem = elem,
			styles = { [0] = {}, {}, {}, {} },
			tasks = {},
		}, class)

		local styles = self.styles
		setmetatable(styles, {
			__index = function(_, k)
				return styles[elem.group][k] or styles[0][k]
			end,
		})
		setmetatable(self.styles[3], {
			__index = function(_, k)
				return self.styles[2][k] or self.styles[1][k] or self.styles[0][k]
			end,
		})

		table.insert(elem.layers, self)
		return self
	end

	local groups = {
		normal = 0,
		click = 2,
		hover = 1,
		hoverClick = 3,
	}

	---@generic self
	---@param self self|FOXStencil.Layer
	---@param styles table
	---@param group string?
	---@return self
	function class:setStyles(styles, group)
		for k, v in pairs(styles) do
			local t = type(v)
			if t == "table" then
				v = { table.unpack(v) }
			elseif t:find("^Vector") then
				v = v:copy()
			end
			self.styles[groups[group] or 0][k] = v
		end

		return self
	end
end
