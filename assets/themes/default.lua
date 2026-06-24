---@class FOXStencil.Themes
---@field default FOXStencil.Themes.Default

local texture = textures:read("ui", string.gsub([[
iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAA
cUlEQVR4XmOUl5f/z0AIgBT9RwLY+CwwQzZu3MigoKDAgI3P
BBK8ePEiigJ0PthNjo6OcBP279+P4UIWbG6eOHEiXDg/P58B
rAibbn9/fwaQtSDVTA8ePGAAORrEAbFhRsAUgPiMGzZsAIcT
yFhcwQUAmJVDEzzGSxcAAAAASUVORK5CYII=]], "%s", ""))

---@class FOXStencil.Themes.Default
local theme = {
	---@type FOXStencil.Button.Theme
	button = {
		-- Standard appearance
		normal = {
			outline = { visible = false, offset_pos = vec(0, -2), offset_size = vec(0, 0) },
			background = { texture = texture, uv_pos = vec(0, 0), uv_size = vec(5, 7), slice = vec(2, 2, 4, 2), offset_pos = vec(0, -2), offset_size = vec(0, 2) },
			label = { text = "Button", pos = vec(3, 1) },
		},

		-- Show outline on hover over
		enter = {
			outline = { visible = true },
		},
		-- Hide outline on hover away
		leave = {
			outline = { visible = false },
		},

		-- Change UV and decrease height by 2 pixels on press
		press = {
			outline = { offset_pos = vec(0, 0), offset_size = vec(0, -2) },
			background = { uv_pos = vec(4, 0), uv_size = vec(5, 5), slice = vec(2, 2, 2, 2), offset_pos = vec(0, 0), offset_size = vec(0, 0) },
			label = { pos = vec(3, 3) },
		},
		-- Change UV and increase height by 2 pixels on release
		release = {
			outline = { offset_pos = vec(0, -2), offset_size = vec(0, 0) },
			background = { uv_pos = vec(0, 0), uv_size = vec(5, 7), slice = vec(2, 2, 4, 2), offset_pos = vec(0, -2), offset_size = vec(0, 2) },
			label = { pos = vec(3, 1) },
		},
	},

	---@type FOXStencil.Window.Theme
	window = {
		-- Standard appearance
		normal = {
			background = { color = vec(0.3, 0.3, 0.3, 1), texture = texture, uv_pos = vec(4, 0), uv_size = vec(5, 5), slice = vec(2, 2, 2, 2), offset_pos = vec(0, 12), offset_size = vec(0, -12) },
			toolbar = { color = vec(0.3, 0.3, 0.3, 1), texture = texture, uv_pos = vec(4, 0), uv_size = vec(5, 5), slice = vec(2, 2, 2, 2), anchor_size = vec(1, 0), offset_size = vec(0, 13) },
			title = { text = "Window", pos = vec(0, 3), align = vec(0.5, 0) },
		},
	},
}

return theme
