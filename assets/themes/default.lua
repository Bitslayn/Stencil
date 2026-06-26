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
		normal = {
			outline = {
				-- Outline visible only when hovered over
				visible = false,

				-- Outline extends vertically when unpressed
				offset_pos = vec(0, -2),
				offset_size = vec(0, 0),
			},
			background = {
				-- Default background texture
				texture = texture,

				-- Unpressed button UV
				uv_pos = vec(0, 0),
				uv_size = vec(5, 7),
				slice = vec(2, 2, 4, 2),

				-- Background extends vertically when unpressed
				offset_pos = vec(0, -2),
				offset_size = vec(0, 2),
			},
			label = {
				-- Default label text
				text = "Button",

				-- Label positioned (3, 3) shifting when background extends
				pos = vec(3, 1),

				-- Label is 6 pixel thinner than element
				offset_width = -6,
			},
		},

		-- Outline visible only when hovered over
		enter = { outline = { visible = true } },

		-- Outline visible only when hovered over
		leave = { outline = { visible = false } },

		press = {
			-- Outline extends vertically when unpressed
			outline = { offset_pos = vec(0, 0), offset_size = vec(0, -2) },

			background = {
				-- Pressed button UV
				uv_pos = vec(4, 0),
				uv_size = vec(5, 5),
				slice = vec(2, 2, 2, 2),

				-- Background extends vertically when unpressed
				offset_pos = vec(0, 0),
				offset_size = vec(0, 0),
			},

			-- Label positioned (3, 3) shifting when background extends
			label = { pos = vec(3, 3) },
		},
		release = {
			-- Outline extends vertically when unpressed
			outline = { offset_pos = vec(0, -2), offset_size = vec(0, 0) },

			background = {
				-- Pressed button UV
				uv_pos = vec(0, 0),
				uv_size = vec(5, 7),
				slice = vec(2, 2, 4, 2),

				-- Background extends vertically when unpressed
				offset_pos = vec(0, -2),
				offset_size = vec(0, 2),
			},

			-- Label positioned (3, 3) shifting when background extends
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
			icon = { text = ":paper:", pos = vec(3, 3), align = vec(0, 0) },
		},
	},
}

return theme
