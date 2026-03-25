-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Core utilities
  "nvim-lua/popup.nvim",
  "nvim-lua/plenary.nvim",

  -- Colorschemes
  { "dracula/vim", name = "dracula" },
  "folke/tokyonight.nvim",
  "navarasu/onedark.nvim",

  -- UI
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  "folke/which-key.nvim",
  "nvim-tree/nvim-tree.lua",

  -- Navigation
  {
    "christoomey/vim-tmux-navigator",
    config = function()
      vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>")
      vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>")
      vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>")
      vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>")
      vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>")
    end,
  },
  {
    "folke/flash.nvim",
    config = function()
      require("flash").setup()
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Editing
  "windwp/nvim-autopairs",
  "numToStr/Comment.nvim",
  {
    "kylechui/nvim-surround",
    version = "*",
    config = function()
      require("nvim-surround").setup()
    end,
  },
  "mechatroner/rainbow_csv",
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("user.gitsigns")
    end,
  },
  "akinsho/toggleterm.nvim",

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdateSync",
    config = function()
      require("user.treesitter")
    end,
  },

  -- Completion
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "super-tab" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        accept = { auto_brackets = { enabled = true } },
      },
      signature = { enabled = true },
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    config = function()
      require("user.conform")
    end,
  },

  -- LSP
  "mason-org/mason.nvim",
  "mason-org/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = { "prettier", "stylua", "black" },
      })
    end,
  },

  -- Kitty scrollback (lazy-loaded)
  {
    "mikesmithgh/kitty-scrollback.nvim",
    lazy = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
    tag = "v4.0.0",
    config = function()
      require("kitty-scrollback").setup()
    end,
  },

  -- Gemini AI (lazy-loaded)
  {
    "marcinjahn/gemini-cli.nvim",
    lazy = true,
    cmd = { "Gemini" },
    keys = {
      { "<leader>a/", "<cmd>Gemini toggle<cr>", desc = "Toggle Gemini CLI" },
      { "<leader>aa", "<cmd>Gemini ask<cr>", mode = { "n", "v" }, desc = "Ask Gemini" },
      { "<leader>af", "<cmd>Gemini add_file<cr>", desc = "Add File" },
    },
    dependencies = { "folke/snacks.nvim" },
    config = function()
      require("gemini-cli").setup({})
    end,
  },
})
