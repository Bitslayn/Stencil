---Generates a button widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Button.Generator fun(parent: FOXStencil.Element, name: string, layers: FOXStencil.Layers, widgets: FOXStencil.Widgets): FOXStencil.Button

---@class FOXStencil.Widgets
---@field button FOXStencil.Button.Generator

---@class FOXStencil.Button
---@field elem FOXStencil.Element
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Button.Styles
local default_styles = {
	text = "Button",
	color = vec(1, 1, 1),
}

---Redraws this button
---@param self FOXStencil.Button
local function draw(self)
	local size = client.getTextDimensions(self.styles.text) + 6

	self.elem:setProps({
		size = size - vec(0, 2),
	})

	self.elem:getLayer("background"):setStyles({
		color = self.styles.color,
		size = size,
	})

	self.elem:getLayer("label"):setStyles({
		text = self.styles.text,
	})

	self.elem:getLayer("outline"):setStyles({
		size = size,
	})
end

local function press()

end

local copy = require("./../core/parser").copy

---Sets the given styles
---@param styles FOXStencil.Button.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.styles) then
		draw(self)
	end

	return self
end

---@param parent FOXStencil.Element
---@param layers FOXStencil.Layers
---@param widgets FOXStencil.Widgets
return function(parent, name, layers, widgets)
	local elem = parent:newElement(name)

	---@class FOXStencil.Button
	local self = {
		elem = elem,
		styles = setmetatable({}, { __index = default_styles }),
	}

	elem:newLayer("background", layers.slice):setStyles({
		pos = vec(0, -2),
		texture = textures["assets.textures.ui"],
		uv_pos = vec(0, 0),
		uv_size = vec(5, 7),
		slice = vec(2, 2, 4, 2),
	})
	elem:newLayer("label", layers.label):setStyles({
		pos = vec(3, 1),
	})
	elem:newLayer("outline", layers.border):setStyles({
		pos = vec(0, -2),
		visible = false,
	})

	function elem.events.hover(_, _, state)
		elem:getLayer("outline"):setStyles({
			visible = state,
		})
	end

	function elem.events.press()
		---@type FOXStencil.Slice
		local background = elem:getLayer("background")
		background:setStyles({
			pos = background.styles.pos + vec(0, 2),
			size = background.styles.size - vec(0, 2),
			uv_pos = vec(4, 0),
			uv_size = vec(5, 5),
			slice = vec(2, 2, 2, 2),
		})

		---@type FOXStencil.Label
		local label = elem:getLayer("label")
		label:setStyles({
			pos = label.styles.pos + vec(0, 2),
		})

		---@type FOXStencil.Border
		local outline = elem:getLayer("outline")
		outline:setStyles({
			pos = outline.styles.pos + vec(0, 2),
			size = outline.styles.size - vec(0, 2),
		})
	end

	function elem.events.release()
		---@type FOXStencil.Slice
		local background = elem:getLayer("background")
		background:setStyles({
			pos = background.styles.pos - vec(0, 2),
			size = background.styles.size + vec(0, 2),
			uv_pos = vec(0, 0),
			uv_size = vec(5, 7),
			slice = vec(2, 2, 4, 2),
		})

		---@type FOXStencil.Label
		local label = elem:getLayer("label")
		label:setStyles({
			pos = label.styles.pos - vec(0, 2),
		})

		---@type FOXStencil.Border
		local outline = elem:getLayer("outline")
		outline:setStyles({
			pos = outline.styles.pos - vec(0, 2),
			size = outline.styles.size + vec(0, 2),
		})
	end

	return setmetatable(self, obj)
end
