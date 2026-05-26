--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

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

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Press
local function press(elem)
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

---@type FOXStencil.Element.Events.Release
local function release(elem)
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

---@type FOXStencil.Element.Events.Hover
local function hover(elem, _, state)
	---@type FOXStencil.Border
	local outline = elem:getLayer("outline")
	outline:setStyles({
		visible = state,
	})
end

---@type FOXStencil.Element.Events.Wrap
local function wrap(elem, width)
	return client.getTextDimensions(elem.widg.styles.text, width - 6).y + 4
end

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	elem:setProps({
		size_min = client.getTextDimensions(string.gsub(elem.widg.styles.text, "%s", "\n")).x_
	})

	---@type FOXStencil.Slice
	local background = elem:getLayer("background")
	background:setStyles({
		color = elem.widg.styles.color,
		size = elem.state.size + vec(0, 2),
	})

	---@type FOXStencil.Label
	local label = elem:getLayer("label")
	label:setStyles({
		text = elem.widg.styles.text,
		width = client.getTextDimensions(elem.widg.styles.text, elem.state.size.x - 6).x,
	})

	---@type FOXStencil.Border
	local outline = elem:getLayer("outline")
	outline:setStyles({
		size = elem.state.size + vec(0, 2),
	})
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Builder ♡˚
--==============================================================================================================================

local copy = require("./../core/parser").copy

---Sets the given styles
---@param styles FOXStencil.Button.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.elem.widg.styles) then
		draw(self.elem)
	end

	return self
end

---@param parent FOXStencil.Element
---@param layers FOXStencil.Layers
---@param widgets FOXStencil.Widgets
return function(parent, name, layers, widgets)
	local elem = parent:newElement(name):setProps({
		size = vec(-1, 0),
		size_min = client.getTextDimensions("Button").x_
	})

	---@class FOXStencil.Button
	local self = { elem = elem }
	elem.widg.styles = setmetatable({}, { __index = default_styles })

	elem:newLayer("background", layers.slice):setStyles({
		pos = vec(0, -2),
		texture = textures["assets.textures.ui"],
		uv_pos = vec(0, 0),
		uv_size = vec(5, 7),
		slice = vec(2, 2, 4, 2),
	})

	elem:newLayer("label", layers.label):setStyles({
		pos = vec(3, 1),
		-- size = 4.5,
		text = "Button",
	})

	elem:newLayer("outline", layers.border):setStyles({
		pos = vec(0, -2),
		visible = false,
	})

	elem.events.press = press
	elem.events.release = release
	elem.events.hover = hover
	elem.events.wrap = wrap
	elem.events.draw = draw

	draw(elem)

	return setmetatable(self, obj)
end

--#ENDREGION
