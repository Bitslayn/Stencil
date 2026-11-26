---@class ReStencil.Theme
local theme = {}

local ui = [[
iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAA
AAcUlEQVR4XmOUl5f/z0AIgBT9RwLY+CwwQzZu3MigoKDA
gI3PBBK8ePEiigJ0PthNjo6OcBP279+P4UIWbG6eOHEiXD
g/P58BrAibbn9/fwaQtSDVTA8ePGAAORrEAbFhRsAUgPiM
GzZsAIcTyFhcwQUAmJVDEzzGSxcAAAAASUVORK5CYII=]]

theme.texture = textures:read("stencil.ui", ui:gsub("%s", ""))

theme.colors = {
	main = vectors.hexToRGB("#4C4C4C"),
	text = vectors.hexToRGB("#FFFFFF"),
	hint = vectors.hexToRGB("#AAAAAA"),

	red = vectors.hexToRGB("red"),
	orange = vectors.hexToRGB("gold"),
	yellow = vectors.hexToRGB("yellow"),
	green = vectors.hexToRGB("green"),
	aqua = vectors.hexToRGB("aqua"),
	blue = vectors.hexToRGB("blue"),
	purple = vectors.hexToRGB("purple"),
}

theme.slices = {
	normal = { texture = theme.texture, pos = vec(4, 0), size = vec(5, 5), slice = vec(2, 2, 2, 2) },
	raised = { texture = theme.texture, pos = vec(0, 0), size = vec(5, 7), slice = vec(2, 2, 4, 2) },
	indent = { texture = theme.texture, pos = vec(4, 4), size = vec(5, 5), slice = vec(2, 2, 2, 2) },
	simple = { texture = theme.texture, pos = vec(2, 6), size = vec(3, 3), slice = vec(1, 1, 1, 1) },
	scroll = { texture = theme.texture, pos = vec(0, 7), size = vec(2, 2), slice = vec(0, 0, 0, 0) },
}

return theme
