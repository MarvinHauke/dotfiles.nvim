-- ============================================================================
-- lua/dotfiles/autocommands.lua - Autocommands
-- ============================================================================

local M = {}

function M.setup(config)
	local dotfiles = require("dotfiles")
	local group = vim.api.nvim_create_augroup("DotfilesGroup", { clear = true })

	-- Auto-detect dotfiles
	vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
		group = group,
		callback = function()
			vim.b.is_dotfile = dotfiles.is_dotfile()
		end,
		desc = "Detect dotfiles",
	})

	-- Auto-refresh cache
	if config.auto_refresh then
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			group = group,
			callback = function()
				local current_file = vim.fn.expand("%:p")
				if vim.startswith(current_file, config.git_dir) then
					dotfiles.refresh()
				end
			end,
			desc = "Auto-refresh dotfiles cache",
		})
	end
end

return M
