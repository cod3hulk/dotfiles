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
      vim.keymap.set("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>")
      vim.keymap.set("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>")
      vim.keymap.set("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>")
      vim.keymap.set("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>")
      vim.keymap.set("n", "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>")
    end,
  },
  "phaazon/hop.nvim",
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
  "akinsho/toggleterm.nvim",

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdateSync",
  },

  -- Completion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "saadparwaiz1/cmp_luasnip",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
  "rafamadriz/friendly-snippets",

  -- LSP
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",

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
