--==============================================================================================================================
--#REGION ˚♡ Class ♡˚
--==============================================================================================================================

---@diagnostic disable: invisible

---Generates a field widget
---@alias FOXStencil.Field.Generator fun(parent: FOXStencil.Element|FOXStencil.Screen, name: string, assets: FOXStencil.Assets): FOXStencil.Field

---@class FOXStencil.Widgets
---@field field FOXStencil.Field.Generator

---@class FOXStencil.Field
local obj = {}
---@package
obj.__index = obj

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Logic ♡˚
--==============================================================================================================================

---@type FOXStencil.Field?
local focused

---@param widg FOXStencil.Field
local function unfocus(widg)
	local caret = widg:getLayer("caret") --[[@as FOXStencil.Sprite]]
	caret:setStyles({ visible = false })

	widg.elem.part.midRender = nil
	events.key_press:remove("field")
	events.char_typed:remove("field")

	focused = nil
end

---@param widg FOXStencil.Field
local function focus(widg)
	-- Handle switched focus

	if focused == widg then
		return
	elseif focused then
		unfocus(focused)
	end

	focused = widg

	-- Animation

	local caret = widg:getLayer("caret") --[[@as FOXStencil.Sprite]]
	widg.elem.part.midRender = function()
		caret:setStyles({ visible = client.getSystemTime() / 500 % 2 > 1 })

		host:chatText("")
	end

	-- Grab input

	--[[TODO
	Ctrl + Left or Right: Next or previous word
	Ctrl + Del or Backspace: Deletes whole word
	Shift + <movement>: Select while moving
	]]

	local keys = {
		[65] = function(mod) -- Select All
			if bit32.band(mod, 2) ~= 2 then return end

			widg:setPos(0, math.huge)
		end,

		[67] = function(mod) -- Copy
			if bit32.band(mod, 2) ~= 2 then return end

			host:clipboard(widg.text:sub(widg.pos, widg.sel))
		end,
		[86] = function(mod) -- Paste
			if bit32.band(mod, 2) ~= 2 then return end

			widg:setText(widg.text:sub(1, widg.pos) .. host:getClipboard() .. widg.text:sub(widg.pos + widg.sel + 1, -1))
			widg:setPos(widg.pos + #host:getClipboard())
		end,
		[88] = function(mod) -- Cut
			if bit32.band(mod, 2) ~= 2 then return end

			host:clipboard(widg.text:sub(widg.pos, widg.sel))
			widg:setText(widg.text:sub(1, widg.pos) .. widg.text:sub(widg.sel + 2, -1))
			widg:setPos(widg.pos)
		end,

		[256] = function() unfocus(widg) end, -- Escape
		[257] = function() unfocus(widg) end, -- Enter

		[259] = function()              -- Backspace
			widg:setText(widg.text:sub(1, math.max(widg.pos - 1, 0)) .. widg.text:sub(widg.pos + widg.sel + 1, -1))
			widg:setPos(widg.pos - 1)
		end,
		[261] = function() -- Delete
			widg:setText(widg.text:sub(1, widg.pos) .. widg.text:sub(widg.pos + widg.sel + 2, -1))
			widg:setPos(widg.pos)
		end,

		[262] = function(mod) -- Right
			-- if bit32.band(mod, 1) == 1 then
			-- 	widg:setPos(widg.pos, widg.sel + 1)
			-- else
			-- 	widg:setPos(widg.pos + math.max(widg.sel, 1))
			-- end
			widg:setPos(widg.pos + 1)
		end,
		[263] = function(mod) -- Left
			widg:setPos(widg.pos - 1)
		end,
		[268] = function(mod) -- Home
			widg:setPos(0)
		end,
		[269] = function(mod) -- End
			widg:setPos(math.huge)
		end,
	}

	events.key_press:register(function(key, state, mod)
		if state == 0 or not keys[key] then return true end

		keys[key](mod)

		return true
	end, "field")

	events.char_typed:register(function(char)
		widg:setText(widg.text:sub(1, widg.pos) .. char .. widg.text:sub(widg.pos + widg.sel + 1, -1))
		widg:setPos(widg.pos + 1)
	end, "field")
end

---@type FOXStencil.Element.Events.Press
local function press(elem, state)
	local widg = elem.widg --[[@as FOXStencil.Field]]
	focus(widg)
end

---@type FOXStencil.Element.Events.Hover
local function hover(elem, state)
	local widg = elem.widg --[[@as FOXStencil.Field]]
	elem:setStyles(widg.theme[state and "enter" or "leave"])
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ Methods ♡˚
--==============================================================================================================================

---@param state boolean?
---@return self
function obj:setFocus(state)
	if state and host:isHost() then
		focus(self)
	else
		unfocus(self)
	end

	return self
end

---@param str string
---@param width integer
local function clip(str, width)
	return str:gsub("[\x00-\x7F\xC2-\xF4][\x80-\xBF]*", function(char)
		width = width - client.getTextWidth(char)
		return width > 0 and char or ""
	end)
end

---@param str string?
---@return self
function obj:setText(str)
	self.text = str or ""

	local text = self:getLayer("text") --[[@as FOXStencil.Text]]
	text:setStyles({ text = clip(self.text, self.state.size.x) })
	local hint = self:getLayer("hint") --[[@as FOXStencil.Text]]
	hint:setStyles({ visible = self.text == "" })

	return self
end

---@param pos integer
---@param sel integer?
---@return self
function obj:setPos(pos, sel)
	self.pos = math.clamp(pos, 0, #self.text)
	self.sel = math.clamp(sel or 0, 0, #self.text + 1)

	local caret = self:getLayer("caret") --[[@as FOXStencil.Sprite]]
	caret:setStyles({ offset_pos = vec(client.getTextWidth(self.text:gsub("%s", '"'):sub(1, self.pos)), 0) + self.theme.normal.caret.offset_pos })

	local select = self:getLayer("select") --[[@as FOXStencil.Sprite]]
	select:setStyles({
		offset_pos = vec(client.getTextWidth(self.text:gsub("%s", '"'):sub(1, self.pos)), 0) + self.theme.normal.select.offset_pos,
		offset_size = vec(client.getTextWidth(self.text:gsub("%s", '"'):sub(self.pos, math.max(self.pos + self.sel - 1, 0))), 11),
	})

	return self
end

---@return string
function obj:getText()
	return self.text
end

---@param theme FOXStencil.Field.Theme
---@return self
function obj:setTheme(theme)
	if self.elem.pressed then self.elem:setStyles(self.theme.release) end
	if self.elem.hovered then self.elem:setStyles(self.theme.leave) end

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
	local elem = parent:newElement(name):setProps({ size = vec(100, 15) })

	---@class FOXStencil.Field: FOXStencil.Element
	---@field text string
	local widg = {
		elem = elem,
		text = "",
		pos = 0,
		sel = 0,
		theme = assets.themes.default.field,
	}
	elem.widg = widg

	function widg:__index(k)
		return obj[k] or elem[k]
	end

	---@class FOXStencil.Field.Theme
	---@field normal FOXStencil.Field.Styles?

	---@class FOXStencil.Field.Styles
	---@field background FOXStencil.Slice.Styles?
	---@field hint FOXStencil.Text.Styles?
	---@field text FOXStencil.Text.Styles?
	---@field outline FOXStencil.Border.Styles?
	---@field caret FOXStencil.Sprite.Styles?

	elem:newLayer("background", assets.layers.slice)
	elem:newLayer("hint", assets.layers.text)
	elem:newLayer("text", assets.layers.text)
	elem:newLayer("outline", assets.layers.border)
	elem:newLayer("caret", assets.layers.sprite)
	elem:newLayer("select", assets.layers.sprite)
	elem:setStyles(widg.theme.normal)

	elem.events = { press = press, hover = hover }

	return setmetatable(widg, widg)
end

--#ENDREGION
