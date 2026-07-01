---@type ClientAPI
local client = {}
local client_meta = figuraMetatables.ClientAPI
local client_index = figuraMetatables.ClientAPI.__index
function client_meta:__index(k)
	return client[k] or client_index[k]
end

-- Credit goes to Auria for discovering this method

---@param text string
---@return boolean
local function check_emoji(text)
	local name = nameplate.LIST:getText()

	local ok = pcall(nameplate.LIST.setText, nameplate.LIST, ("a"):rep(63) .. text)
	nameplate.LIST:setText(name)

	return ok
end

---@param text string
---@return string, integer
local function fix_emojis(text)
	return text:gsub("%b::", function(w)
		return check_emoji(w) and ":..:" or w
	end)
end

function client.getTextDimensions(text, ...)
	return client_index.getTextDimensions(fix_emojis(text), ...)
end

function client.getTextWidth(text)
	return client_index.getTextWidth(fix_emojis(text))
end
