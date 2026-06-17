---@class FOXStencil.Themes
---@field default FOXStencil.Themes.Default

local texture = string.gsub([[
iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAA
cUlEQVR4XmOUl5f/z0AIgBT9RwLY+CwwQzZu3MigoKDAgI3P
BBK8ePEiigJ0PthNjo6OcBP279+P4UIWbG6eOHEiXDg/P58B
rAibbn9/fwaQtSDVTA8ePGAAORrEAbFhRsAUgPiMGzZsAIcT
yFhcwQUAmJVDEzzGSxcAAAAASUVORK5CYII=]], "%s", "")

---@class FOXStencil.Themes.Default
local theme = {
	texture = textures:read("ui", texture),
}

return theme
