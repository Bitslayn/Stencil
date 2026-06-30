---@class FOXStencil.Themes
---@field default FOXStencil.Themes.Default

local texture = textures:read("ui", string.gsub([[
iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAA
cUlEQVR4XmOUl5f/z0AIgBT9RwLY+CwwQzZu3MigoKDAgI3P
BBK8ePEiigJ0PthNjo6OcBP279+P4UIWbG6eOHEiXDg/P58B
rAibbn9/fwaQtSDVTA8ePGAAORrEAbFhRsAUgPiMGzZsAIcT
yFhcwQUAmJVDEzzGSxcAAAAASUVORK5CYII=]], "%s", ""))

local sprites = {
	---UV typically used for pressed buttons. Considers itself average compared to the other sprites.
	normal = { pos = vec(4, 0), size = vec(5, 5), slice = vec(2, 2, 2, 2) },
	---UV typically used for unpressed buttons. It stands there proudly waiting to be pressed.
	raised = { pos = vec(0, 0), size = vec(5, 7), slice = vec(2, 2, 4, 2) },
	---UV typically used for container backgrounds. Would likely bite you for calling it short.
	invert = { pos = vec(4, 4), size = vec(5, 5), slice = vec(2, 2, 2, 2) },
	---UV typically used for text field backgrounds. It probably has a crush on Mr. Clean.
	simple = { pos = vec(2, 6), size = vec(3, 3), slice = vec(1, 1, 1, 1) },
	---UV typically used for scrollbars. It may not have a solid black border like the other sprites, but it sure knows its way around.
	scroll = { pos = vec(0, 7), size = vec(2, 2), slice = vec(0, 0, 0, 0) },
}

---@class FOXStencil.Themes.Default
local theme = {
	---Button that extends 2 pixels vertically upwards. Contracts when
	---pressed and has an outline when hovered over.
	---@type FOXStencil.Button.Theme
	button = {
		-- Styles applied upon creation, same as unhovered + released
		normal = {
			outline = {
				-- Hide outline when not hovered
				visible = false,

				-- Outline shifted vertically, extend bottom by same amount
				offset_pos = vec(0, -2),
				offset_size = vec(0, 0),
			},
			background = {
				-- Default texture
				texture = texture,

				-- Unpressed button UV
				uv_pos = sprites.raised.pos,
				uv_size = sprites.raised.size,
				slice = sprites.raised.slice,

				-- Background shifted vertically, extend bottom by same amount
				offset_pos = vec(0, -2),
				offset_size = vec(0, 2),
			},
			label = {
				-- Default label text
				text = "Button",

				-- Label is 6 pixels thinner than element
				offset_width = -6,

				-- Center label and raise to match background extension
				align = vec(0.5, 0.5),
				offset_pos = vec(0, -2),
			},
		},

		-- Hover styles
		enter = {
			-- Show outline when hovered
			outline = { visible = true },
		},
		leave = {
			-- Hide outline when hovered away
			outline = { visible = false },
		},

		-- Press styles
		press = {
			outline = {
				-- Outline shifted vertically, contract bottom by same amount
				offset_pos = vec(0, 0),
				offset_size = vec(0, -2),
			},

			background = {
				-- Pressed button UV
				uv_pos = sprites.normal.pos,
				uv_size = sprites.normal.size,
				slice = sprites.normal.slice,

				-- Background shifted vertically, contract bottom by same amount
				offset_pos = vec(0, 0),
				offset_size = vec(0, 0),
			},

			label = {
				-- Center label and lower to match background contraction
				offset_pos = vec(0, 0),
			},
		},
		release = {
			outline = {
				-- Outline shifted vertically, extend bottom by same amount
				offset_pos = vec(0, -2),
				offset_size = vec(0, 0),
			},

			background = {
				-- Unpressed button UV
				uv_pos = sprites.raised.pos,
				uv_size = sprites.raised.size,
				slice = sprites.raised.slice,

				-- Background shifted vertically, extend bottom by same amount
				offset_pos = vec(0, -2),
				offset_size = vec(0, 2),
			},

			label = {
				-- Center label and raise to match background extension
				offset_pos = vec(0, -2),
			},
		},
	},

	---Just a label.
	---@type FOXStencil.Label.Theme
	label = {
		-- Styles applied upon creation
		normal = {
			label = {
				-- Default text
				text = "Label",
			},
		},
	},

	---Container with a title and icon.
	---@type FOXStencil.Window.Theme
	window = {
		-- Styles applied upon creation
		normal = {
			background = {
				-- Default Color
				color = vectors.hexToRGB("#3B3B3B"),

				-- Default texture
				texture = texture,

				-- Container UV
				uv_pos = sprites.invert.pos,
				uv_size = sprites.invert.size,
				slice = sprites.invert.slice,

				-- Align to bottom and size to container height, overlapping toolbar by 1 pixel
				offset_pos = vec(0, 12),
				offset_size = vec(0, -12),
			},
			toolbar = {
				-- Default Color
				color = vectors.hexToRGB("#555555"),

				-- Default texture
				texture = texture,

				-- Normal UV
				uv_pos = sprites.normal.pos,
				uv_size = sprites.normal.size,
				slice = sprites.normal.slice,

				-- Align to top and size to 13 pixels
				anchor_size = vec(1, 0),
				offset_size = vec(0, 13),
			},
			title = {
				-- Default title text
				text = "Window",

				---Center align
				offset_pos = vec(0, 3),
				align = vec(0.5, 0),
			},
			icon = {
				-- Default icon emoji
				text = ":paper:",

				-- Left align
				offset_pos = vec(3, 3),
				align = vec(0, 0),
			},
		},
	},
}

return theme
