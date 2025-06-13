# dotfiles.nvim

A Neovim plugin for seamless dotfiles management with bare git repositories.

## ✨ Features

- 🚀 **Fast file detection** - Cached lookup of tracked dotfiles
- 🔄 **Auto-refresh** - Automatically updates cache when dotfiles change
- 📁 **Interactive file browser** - List and open dotfiles with ease
- 🎯 **Git integration** - Works with gitsigns, fugitive, and other git plugins
- 📊 **Status monitoring** - Check dotfiles git status
- ⚡ **Statusline integration** - Show dotfile indicator in statusline
- 🛠️ **Configurable** - Customize keymaps, notifications, and behavior

## 📋 Requirements

- Neovim >= 0.8.0
- A dotfiles setup using bare git repository (e.g., `~/.cfg`)
- Git command line tool

## 🛠️ Dotfiles Setup

This plugin works with the common "bare repository" dotfiles setup:

```bash
# Initial setup
git init --bare $HOME/.cfg
alias dotfiles='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no

# Add files
dotfiles add .vimrc
dotfiles commit -m "Add vimrc"
```

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "MarvinHauke/dotfiles.nvim",
  config = function()
    require("dotfiles").setup({
      -- Optional configuration
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "MarvinHauke/dotfiles.nvim",
  config = function()
    require("dotfiles").setup()
  end
}
```

## ⚙️ Configuration

Default configuration:

```lua
require("dotfiles").setup({
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
      list = "f",        -- <leader>df - List dotfiles
      check = "c",       -- <leader>dc - Check if current file is dotfile
      add = "a",         -- <leader>da - Add current file to dotfiles
      status = "s",      -- <leader>ds - Show dotfiles status
      refresh = "r",     -- <leader>dr - Refresh cache
    },
  },

  -- Statusline integration
  statusline = {
    enable = true,
    icon = "📁",
  },
})
```

## 🚀 Usage

### Commands

- `:DotfilesList` - Interactive list of all tracked dotfiles
- `:DotfilesCheck` - Check if current file is tracked
- `:DotfilesAdd` - Add current file to dotfiles repository
- `:DotfilesStatus` - Show git status of dotfiles
- `:DotfilesRefresh` - Manually refresh the cache

### Keymaps (default)

- `<leader>df` - List dotfiles
- `<leader>dc` - Check current file
- `<leader>da` - Add current file
- `<leader>ds` - Show status
- `<leader>dr` - Refresh cache

### API

```lua
local dotfiles = require("dotfiles")

-- Check if a file is tracked
dotfiles.is_tracked("/home/user/.vimrc") -- returns true/false

-- Check if current buffer is a dotfile
dotfiles.is_dotfile() -- returns true/false

-- Get git command for current file (for plugin integration)
dotfiles.get_git_cmd() -- returns {"git"} or {"git", "--git-dir=...", "--work-tree=..."}

-- Refresh the cache
dotfiles.refresh()

-- Get all tracked files
dotfiles.get_tracked_files() -- returns table of filepath -> true
```

## 🔌 Git Plugin Integration

### Gitsigns

```lua
{
  "lewis6991/gitsigns.nvim",
  config = function()
    local dotfiles = require("dotfiles")

    require("gitsigns").setup({
      worktrees = {
        {
          toplevel = dotfiles.get_config().work_tree,
          gitdir = dotfiles.get_config().git_dir,
        },
      },
      -- ... other config
    })
  end,
}
```

### Git-blame.nvim

```lua
{
  "f-person/git-blame.nvim",
  opts = {
    git_command = function()
      return require("dotfiles").get_git_cmd_string()
    end,
  },
}
```

## 📊 Statusline Integration

### With lualine

```lua
{
  "nvim-lualine/lualine.nvim",
  opts = {
    sections = {
      lualine_c = {
        "filename",
        {
          function() return require("dotfiles").statusline() end,
          color = { fg = "#f7768e" },
        },
      },
    },
  },
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see LICENSE file for details.
