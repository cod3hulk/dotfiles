local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  print "packer not found"
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

return packer.startup(function(use)
  -- My plugins
  use "wbthomason/packer.nvim" -- Have packer manage itself
  use "nvim-lua/popup.nvim"    -- An implementation of the Popup API from vim in Neovim
  use "windwp/nvim-autopairs"  -- Autopairs, integrates with both cmp and treesitter
  use "numToStr/Comment.nvim"
  use "phaazon/hop.nvim"
  use "akinsho/toggleterm.nvim"
  use "mechatroner/rainbow_csv"
  use "tpope/vim-fugitive"
  -- use "pabloariasal/webify.nvim"
  use({
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  })
  -- use {
  --   'nvim-lualine/lualine.nvim',
  --   requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  -- }

  -- colorscheme
  use { 'dracula/vim', as = 'dracula' }
  use 'folke/tokyonight.nvim'
  use 'navarasu/onedark.nvim'

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdateSync'
  }

  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }

  -- which-key
  use "folke/which-key.nvim"

  -- nvim-tree
  use "nvim-tree/nvim-tree.lua"

  -- cmp plugins
  use "hrsh7th/nvim-cmp"         -- The completion plugin
  use "hrsh7th/cmp-buffer"       -- buffer completions
  use "hrsh7th/cmp-path"         -- path completions
  use "hrsh7th/cmp-cmdline"      -- cmdline completions
  use "saadparwaiz1/cmp_luasnip" -- snippet completions
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-nvim-lua"

  -- snippets
  use "L3MON4D3/LuaSnip"             --snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- LSP
  use "williamboman/mason.nvim" -- simple to use language server installer
  use "williamboman/mason-lspconfig.nvim"
  use "neovim/nvim-lspconfig"   -- enable LSP
  --
  -- -- ChatGPT
  -- use "robitx/gp.nvim"
  --
  -- Kitty scrollback
  use({
    'mikesmithgh/kitty-scrollback.nvim',
    disable = false,
    opt = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    -- tag = '*', -- latest stable version, may have breaking changes if major version changed
    tag = 'v4.0.0', -- pin specific tag
    config = function()
      require('kitty-scrollback').setup()
    end,
  })

  -- Gemini
  use {
    "marcinjahn/gemini-cli.nvim",
    -- 'cmd' defines which commands trigger the lazy-load
    cmd = { "Gemini" },

    -- Packer handles keybindings via the 'setup' or 'config' function
    -- or via the 'keys' keyword if using a specific packer extension.
    -- The most reliable way is to define them manually:
    setup = function()
      vim.keymap.set("n", "<leader>a/", "<cmd>Gemini toggle<cr>", { desc = "Toggle Gemini CLI" })
      vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>Gemini ask<cr>", { desc = "Ask Gemini" })
      vim.keymap.set("n", "<leader>af", "<cmd>Gemini add_file<cr>", { desc = "Add File" })
    end,

    requires = {
      "folke/snacks.nvim",
    },

    -- In lazy.nvim, 'config = true' automatically calls require("gemini-cli").setup({})
    -- In Packer, you must do this explicitly:
    config = function()
      require("gemini-cli").setup({})
    end,
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
