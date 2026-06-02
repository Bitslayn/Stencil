---@class FOXStencil.Themes
---@field ui FOXStencil.Themes.UI

local path = table.concat({ ... }, "."):gsub("(%w)/(%w)", "%1.%2")

---@class FOXStencil.Themes.UI
local theme = {
	textures = { ui = textures[path] },
}

return theme
