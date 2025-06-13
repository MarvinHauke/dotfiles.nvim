-- ============================================================================
-- lua/dotfiles/init.lua - Main module
-- ============================================================================

local M = {}

-- Default configuration
local default_config = {
	-- Git directory for dotfiles (bare repo)
	git_dir = os.getenv("HOME") .. "/.cfg",

	-- Working tree (usually home directory)
	work_tree = os.getenv("HOME"),

	-- Auto-refresh cache when dotfiles directory changes
	auto_refresh = true,

	-- Show notifications
	notifications = true,

	-- Auto-detect dotfiles on buffer enter
	auto_detect = true,

	-- Keymaps
	keymaps = {
		enable = true,
		prefix = "<leader>d",
		mappings = {
			list = "f", -- <leader>df
			check = "c", -- <leader>dc
			add = "a", -- <leader>da
			status = "s", -- <leader>ds
			refresh = "r", -- <leader>dr
		},
	},

	-- Statusline integration
	statusline = {
		enable = true,
		icon = "📁",
	},

	-- Signs configuration (for future gutter signs feature)
	signs = {
		enable = false,
		modified = "M",
		added = "A",
		deleted = "D",
	},
}

-- Plugin state
local config = {}
local tracked_files = nil

-- Internal functions
local function notify(msg, level)
	if config.notifications then
		vim.notify(msg, level or vim.log.levels.INFO)
	end
end

local function load_tracked_files()
	local stat = vim.loop.fs_stat(config.git_dir)
	if not stat or stat.type ~= "directory" then
		return {}
	end

	local handle = io.popen(string.format("git --git-dir=%s --work-tree=%s ls-files", config.git_dir, config.work_tree))

	if not handle then
		return {}
	end

	local output = handle:read("*a")
	local success, _, exit_code = handle:close()

	if not success or exit_code ~= 0 then
		return {}
	end

	local files = {}
	for line in output:gmatch("[^\r\n]+") do
		if line and line ~= "" then
			files[config.work_tree .. "/" .. line] = true
		end
	end

	return files
end

-- Public API
function M.is_tracked(filepath)
	if not tracked_files then
		tracked_files = load_tracked_files()
	end
	return tracked_files[filepath] or false
end

function M.refresh()
	tracked_files = load_tracked_files()
	if config.notifications then
		notify("🔄 Dotfiles cache refreshed")
	end
end

function M.is_dotfile()
	local current_file = vim.fn.expand("%:p")
	return M.is_tracked(current_file)
end

function M.get_tracked_files()
	if not tracked_files then
		tracked_files = load_tracked_files()
	end
	return tracked_files
end

function M.get_git_cmd()
	local current_file = vim.fn.expand("%:p")
	if M.is_tracked(current_file) then
		return { "git", "--git-dir=" .. config.git_dir, "--work-tree=" .. config.work_tree }
	end
	return { "git" }
end

function M.get_git_cmd_string()
	local current_file = vim.fn.expand("%:p")
	if M.is_tracked(current_file) then
		return "git --git-dir=" .. config.git_dir .. " --work-tree=" .. config.work_tree
	end
	return "git"
end

function M.get_config()
	return config
end

-- Setup function
function M.setup(user_config)
	-- Merge user config with defaults
	config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- Load submodules
	require("dotfiles.commands").setup(config)

	if config.auto_detect then
		require("dotfiles.autocommands").setup(config)
	end

	-- Set up keymaps
	if config.keymaps.enable then
		local prefix = config.keymaps.prefix
		local maps = config.keymaps.mappings

		vim.keymap.set("n", prefix .. maps.list, "<cmd>DotfilesList<cr>", { desc = "📁 List dotfiles" })
		vim.keymap.set("n", prefix .. maps.check, "<cmd>DotfilesCheck<cr>", { desc = "🔍 Check if dotfile" })
		vim.keymap.set("n", prefix .. maps.add, "<cmd>DotfilesAdd<cr>", { desc = "➕ Add to dotfiles" })
		vim.keymap.set("n", prefix .. maps.status, "<cmd>DotfilesStatus<cr>", { desc = "📊 Dotfiles status" })
		vim.keymap.set("n", prefix .. maps.refresh, "<cmd>DotfilesRefresh<cr>", { desc = "🔄 Refresh cache" })
	end

	-- Initialize cache
	M.refresh()
end

-- Statusline function for integration
function M.statusline()
	if not config.statusline.enable then
		return ""
	end

	if M.is_dotfile() then
		return config.statusline.icon .. " "
	end

	return ""
end

return M
