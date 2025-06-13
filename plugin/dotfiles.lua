-- ============================================================================
-- plugin/dotfiles.lua - Auto-loaded entry point
-- ============================================================================

if vim.g.loaded_dotfiles then
	return
end
vim.g.loaded_dotfiles = 1

-- Only load if we have a dotfiles setup
local home = os.getenv("HOME")
local dotfiles_dir = home .. "/.cfg"

if vim.fn.isdirectory(dotfiles_dir) ~= 1 then
	return
end

-- Setup the plugin
require("dotfiles").setup()
