---@class FOXStencil.Themes
---@field stencil FOXStencil.Themes.Stencil

local texture = string.gsub([[
iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJBAMAAAASvxsjAAAA
D1BMVEUfHx9gYGCwsLDQ0ND///9WEhsNAAAAL0lEQVR4XhXH
QQ3AMAwEMC89AqOwQAiElj+mqR9LBuTkkE6zZg3Py7U+qM1O
Dbd+QucCduJb5QsAAAAASUVORK5CYII=]], "%s", "")

---@class FOXStencil.Themes.Stencil
local theme = {
	texture = textures:read("ui", texture),
}

return theme
