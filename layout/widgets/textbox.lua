--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

-- WIP!!!

---Generates a textbox widget
---
---Call :setConfigs() with a table to change the configs
---@alias FOXStencil.Textbox.Generator fun(parent: FOXStencil.Element, name: string, layers: FOXStencil.Layers, widgets: FOXStencil.Widgets): FOXStencil.Textbox

---@class FOXStencil.Widgets
---@field textbox FOXStencil.Textbox.Generator

---@alias FOXStencil.Textbox.Press fun(widg: FOXStencil.Textbox)
---@alias FOXStencil.Textbox.Release fun(widg: FOXStencil.Textbox)

---@class FOXStencil.Textbox
---@field elem FOXStencil.Element
local obj = {}
---@package
obj.__index = obj

---@class FOXStencil.Textbox.Styles
local default_styles = {
	---@type string
	hint = "",
	---@type number
	width = 100,
}

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Events ♡˚
--==============================================================================================================================

---@type FOXStencil.Element.Events.Draw
local function draw(elem)
	elem:setProps({
		size = vec(elem.widg.styles.width, 9 + 4),
	})

	---@type FOXStencil.Slice
	local background = elem:getLayer("background")
	background:setStyles({
		size = elem.state.size,
		color = vec(0.2, 0.2, 0.2),

		texture = textures["assets.textures.ui"],
		uv_pos = vec(4, 4),
		uv_size = vec(5, 5),
		slice = vec(2, 2, 2, 2),
	})

	---@type string
	local text = elem.widg.text
	---@type string
	local hint = elem.widg.styles.hint

	---@type FOXStencil.Text
	local label = elem:getLayer("label")
	label:setStyles({
		pos = vec(3, 3),

		text = text ~= "" and text or hint,
	})

	---@type FOXStencil.Border
	local outline = elem:getLayer("outline")
	outline:setStyles({
		size = elem.state.size,
	})

	---@type FOXStencil.Sprite
	local caret = elem:getLayer("caret")
	caret:setStyles({
		pos = vec(3 + client.getTextWidth(text:gsub("%s", "..")), 2),
		size = vec(1, 9),
	})
end

---@param elem FOXStencil.Element
local function capture(elem)
	---@type FOXStencil.Sprite
	local caret = elem:getLayer("caret")
	local function tick()
		caret:setStyles({
			visible = client.getSystemTime() / 1000 % 1 < 0.5,
		})
	end

	---@type Event.CharTyped.func
	local function char_typed(char)
		elem.widg.text = elem.widg.text .. char:gsub("%s", " ")
		draw(elem)
	end

	---@type Event.KeyPress.func
	local function key_press(key, state)
		if state == 0 then return end
		if key == 259 then
			elem.widg.text = string.sub(elem.widg.text, 1, -2)
			draw(elem)
		end
	end

	events.tick:register(tick)
	events.char_typed:register(char_typed)
	events.key_press:register(key_press)

	return function()
		events.tick:remove(tick)
		events.char_typed:remove(char_typed)
	end
end

---@type FOXStencil.Element.Events.Press
local function press(elem)
	if not elem.widg.capture then
		elem.widg.capture = capture(elem)
	end
end

---@type FOXStencil.Element.Events.Release
local function release(elem)

end

---@type FOXStencil.Element.Events.Hover
local function hover(elem, _, state)
	---@type FOXStencil.Border
	local outline = elem:getLayer("outline")
	outline:setStyles({
		visible = state,
	})

	-- TODO In case of dragging and selecting text, a hover and release would be needed
end


--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

local copy = require("./../core/parser").copy

---Sets the given styles
---@param styles FOXStencil.Textbox.Styles
---@return self
function obj:setStyles(styles)
	if copy(styles, self.elem.widg.styles) then
		draw(self.elem)
	end

	return self
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Builder ♡˚
--==============================================================================================================================

---@param parent FOXStencil.Element
---@param layers FOXStencil.Layers
---@param widgets FOXStencil.Widgets
return function(parent, name, layers, widgets)
	local elem = parent:newElement(name)

	---@class FOXStencil.Textbox
	local widg = { elem = elem, text = "" }
	elem.widg = widg

	widg.styles = setmetatable({}, { __index = default_styles })

	elem:newLayer("background", layers.slice)
	elem:newLayer("label", layers.text)
	elem:newLayer("outline", layers.border):setStyles({ visible = false })
	elem:newLayer("caret", layers.sprite):setStyles({ visible = false })

	elem.events.draw = draw
	elem.events.press = press
	elem.events.release = release
	elem.events.hover = hover

	draw(elem)

	return setmetatable(widg, obj)
end

--#ENDREGION
