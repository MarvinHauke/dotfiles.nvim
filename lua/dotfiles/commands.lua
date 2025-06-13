-- ============================================================================
-- lua/dotfiles/commands.lua - User commands
-- ============================================================================

local M = {}

function M.setup(config)
	local dotfiles = require("dotfiles")

	-- List all tracked dotfiles
	vim.api.nvim_create_user_command("DotfilesList", function()
		local tracked = dotfiles.get_tracked_files()
		local files = {}

		for filepath, _ in pairs(tracked) do
			table.insert(files, filepath)
		end

		if #files == 0 then
			vim.notify("No dotfiles found", vim.log.levels.WARN)
			return
		end

		table.sort(files)

		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf, "Dotfiles List")

		local content = { "# Tracked Dotfiles (" .. #files .. " files)", "" }

		for _, filepath in ipairs(files) do
			local relative = filepath:sub(#config.work_tree + 2)
			table.insert(content, "  " .. relative)
		end

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
		vim.api.nvim_buf_set_option(buf, "modifiable", false)
		vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

		vim.cmd("split")
		vim.api.nvim_win_set_buf(0, buf)

		vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = buf, desc = "Close" })
		vim.keymap.set("n", "<CR>", function()
			local line = vim.api.nvim_get_current_line()
			local filepath = line:match("^%s*(.-)%s*$")
			if filepath and filepath ~= "" and not filepath:match("^#") then
				local full_path = config.work_tree .. "/" .. filepath
				vim.cmd("edit " .. vim.fn.fnameescape(full_path))
			end
		end, { buffer = buf, desc = "Open file" })
	end, { desc = "List all tracked dotfiles" })

	-- Check if current file is a dotfile
	vim.api.nvim_create_user_command("DotfilesCheck", function()
		local current_file = vim.fn.expand("%:p")
		if current_file == "" then
			vim.notify("No file in current buffer", vim.log.levels.WARN)
			return
		end

		local is_dotfile = dotfiles.is_tracked(current_file)
		local relative_path = current_file:sub(#config.work_tree + 2)

		if is_dotfile then
			vim.notify("✅ " .. relative_path .. " is a tracked dotfile", vim.log.levels.INFO)
		else
			vim.notify("❌ " .. relative_path .. " is NOT a tracked dotfile", vim.log.levels.INFO)
		end
	end, { desc = "Check if current file is a tracked dotfile" })

	-- Add more commands here...
end

return M
