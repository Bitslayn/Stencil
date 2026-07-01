--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a slider widget
---@alias FOXStencil.Slider.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Slider

---@class FOXStencil.Widgets
---@field slider FOXStencil.Slider.Generator

---@class FOXStencil.Slider
local obj = {}
---@package
obj.__index = obj

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Logic ♡˚
--==============================================================================================================================

-- Hover styles

---@type FOXStencil.Element.Events.Hover
local function hover(elem, state)
	local widg = elem.widg --[[@as FOXStencil.Slider]]
	elem:setStyles(widg.theme[state and "enter" or "leave"])
end

-- Slider dragging

---@type FOXStencil.Element.Events.Press
local function press() end

---@type FOXStencil.Element.Events.Drag
local function drag(elem)
	local widg = elem.widg --[[@as FOXStencil.Slider]]
	local thumb = elem:getLayer("thumb") --[[@as FOXStencil.Slice]]

	local pointer_pos = elem.pointer.elem_pos.x
	local gutter_size = elem.state.size.x
	local thumb_size = thumb.state.size.x / gutter_size
	local steps = widg.steps - 1

	local pos = pointer_pos / gutter_size - thumb_size / 2
	pos = pos / (1 - thumb_size)

	pos = math.round(pos * steps) / steps
	pos = math.clamp(pos, 0, 1)

	pos = pos * (1 - thumb_size)
	thumb:setStyles({ anchor_pos = vec(pos, 0) })
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

---@param theme FOXStencil.Slider.Theme
---@return self
function obj:setTheme(theme)
	self.theme = theme
	self.elem:setStyles(theme.normal)
	return self
end

---@return number
function obj:getProgress()
	local thumb = self.elem:getLayer("thumb") --[[@as FOXStencil.Slice]]

	return thumb.styles.anchor_pos.x / (1 - thumb.styles.anchor_size.x)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Builder ♡˚
--==============================================================================================================================

---@param parent FOXStencil.Element|FOXStencil.Screen
---@param assets FOXStencil.Assets
return function(parent, name, assets)
	local elem = parent:newElement(name):setProps({ size = vec(100, 15) })

	---@class FOXStencil.Slider: FOXStencil.Element
	local widg = {
		elem = elem,
		theme = assets.themes.default.slider,
		steps = 3
	}
	elem.widg = widg

	function widg:__index(k)
		return obj[k] or elem[k]
	end

	---@class FOXStencil.Slider.Theme
	---@field normal FOXStencil.Slider.Styles?
	---@field enter FOXStencil.Slider.Styles?
	---@field leave FOXStencil.Slider.Styles?

	---@class FOXStencil.Slider.Styles
	---@field background FOXStencil.Slice.Styles?
	---@field thumb FOXStencil.Slice.Styles?
	---@field outline FOXStencil.Border.Styles?

	elem:newLayer("background", assets.layers.slice)
	elem:newLayer("thumb", assets.layers.slice)
	elem:newLayer("outline", assets.layers.border)
	elem:setStyles(widg.theme.normal)

	elem.events = { press = press, hover = hover, drag = drag }

	return setmetatable(widg, widg)
end

--#ENDREGION
