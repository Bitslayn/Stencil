# Overview

The goal is to allow baking and reusing elements.

```lua
local close_button = stencil.widget.button:new({
	label = "Close",
	color = stencil.theme.colors.caution
})

function close_button.onClick(self)
	self.parent:remove()
end
```

Under the surface, elements are constructed from layouts.

```lua
layout:new({
	slice = theme.slices.button,
	color = styles.color or theme.colors.primary,

	direction = "horizontal",

	child = {
		{
			label = styles.label or "Button",
		},
	},
})
```

Some elements might require complex functionality, like windows for example. A toolbar with a close button might want to index its parent. You may also need to index through a window to access its children.

```lua
local example_window = stencil.containers.window:new({
	id = "example_window",
	title = "Window",
})

local month_dropdown = stencil.widget.dropdown:new({
	id = "month_dropdown",
	content = { "Jan", "Feb", "Mar" },
})

example_window:addChild(month_dropdown)
```