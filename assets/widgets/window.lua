--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a window widget
---@alias FOXStencil.Window.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Window

---@class FOXStencil.Widgets
---@field window FOXStencil.Window.Generator

---@class FOXStencil.Window
local obj = {}
---@package
obj.__index = obj

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Logic ♡˚
--==============================================================================================================================

-- Window dragging

---@type FOXStencil.Element.Events.Press
local function press(elem)
	elem:setIndex(-1)
	return elem.pointer.elem_pos.y > 13
end

---@type FOXStencil.Element.Events.Drag
local function drag(elem, move)
	elem:setProps({ pos = elem.props.pos + move })
end

-- Text wrapping

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	local title = elem:getLayer("title") --[[@as FOXStencil.Text]]
	local title_size = title.styles.size / 9
	local icon = elem:getLayer("icon") --[[@as FOXStencil.Text]]
	local icon_size = icon.styles.size / 9

	elem:setProps({ size = vec(client.getTextWidth(icon.styles.text) * icon_size + client.getTextWidth(title.styles.text) * title_size + 6, 0) })
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

---@param theme FOXStencil.Window.Theme
---@return self
function obj:setTheme(theme)
	self.theme = theme
	self.elem:setStyles(theme.normal)
	return self
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Builder ♡˚
--==============================================================================================================================

---@param parent FOXStencil.Element|FOXStencil.Screen
---@param assets FOXStencil.Assets
return function(parent, name, assets)
	local elem = parent:newElement(name):setProps({ padding = vec(15, 3, 3, 3), direction = "VERTICAL" })

	---@class FOXStencil.Window: FOXStencil.Element
	local widg = {
		elem = elem,
		theme = assets.themes.default.window,
	}
	elem.widg = widg

	function widg:__index(k)
		return obj[k] or elem[k]
	end

	---@class FOXStencil.Window.Theme
	---@field normal FOXStencil.Window.Styles?

	---@class FOXStencil.Window.Styles
	---@field background FOXStencil.Slice.Styles?
	---@field toolbar FOXStencil.Slice.Styles?
	---@field title FOXStencil.Text.Styles?
	---@field icon FOXStencil.Text.Styles?

	elem:newLayer("background", assets.layers.slice)
	elem:newLayer("toolbar", assets.layers.slice)
	elem:newLayer("title", assets.layers.text)
	elem:newLayer("icon", assets.layers.text)
	elem:setStyles(widg.theme.normal)

	elem.events = { press = press, drag = drag, draw = draw }

	return setmetatable(widg, widg)
end

--#ENDREGION
