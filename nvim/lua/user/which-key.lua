local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  print("which-key not found")
  return
end

local setup = {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = false, -- adds help for motions
      text_objects = false, -- help for text objects triggered after entering an operator
      windows = false, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
  -- add operators that will trigger motion and text object completion
  -- to enable all native operators, set the preset / operators plugin above
  -- operators = { gc = "Comments" },
  -- key_labels = {
    -- override the label used to display some keys. It doesn't effect WK in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
  -- },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },
  -- popup_mappings = {
    -- scroll_down = "<c-d>", -- binding to scroll down inside the popup
    -- scroll_up = "<c-u>", -- binding to scroll up inside the popup
  -- },
  -- window = {
    -- border = "rounded", -- none, single, double, shadow
    -- position = "bottom", -- bottom, top
    -- margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    -- padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    -- winblend = 0,
  -- },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  -- ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
  -- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
  show_help = true, -- show help message on the command line when the popup is visible
  -- triggers = "auto", -- automatically setup triggers
  -- triggers = {"<leader>"} -- or specify a list manually
  -- triggers_blacklist = {
    -- list of mode / prefixes that should never be hooked by WhichKey
    -- this is mostly relevant for key maps that start with a native binding
    -- most people should not need to change this
    -- i = { "f", "d" },
    -- v = { "f", "d" },
  -- },
}

local opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local mappings =   {
    { "<leader>f", group = "find", nowait = true, remap = false },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers", nowait = true, remap = false },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", nowait = true, remap = false },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep File", nowait = true, remap = false },
    { "<leader>fn", "<cmd>:new<cr>", desc = "New File", nowait = true, remap = false },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Open Recent File", nowait = true, remap = false },

    { "<leader>j", group = "jump", nowait = true, remap = false },
    { "<leader>jj", "<cmd>HopChar1<cr>", desc = "Jump Char", nowait = true, remap = false },
    { "<leader>jw", "<cmd>HopWord<cr>", desc = "Jump Word", nowait = true, remap = false },

    { "<leader>l", group = "LSP", nowait = true, remap = false },
    { "<leader>lf", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", desc = "Format", nowait = true, remap = false },
    { "<leader>li", "<cmd>LspInstallInfo<cr>", desc = "Install LanguageServer", nowait = true, remap = false },

    { "<leader>g", group = "Git", nowait = true, remap = false },
    { "<leader>gb", "<cmd>G blame<cr>", desc = "Blame", nowait = true, remap = false },

    { "<leader>q", "<cmd>:q<cr>", desc = "Close File", nowait = true, remap = false },
    { "<leader>w", "<cmd>:w<cr>", desc = "Write File", nowait = true, remap = false },
    { "<leader>x", "<cmd>:x<cr>", desc = "Write And Close File", nowait = true, remap = false },
    { "<leader>e", "<cmd>:NvimTreeToggle<cr>", desc = "Toggle File Explorer", nowait = true, remap = false },
}


-- local mappings = {
--   f = {
--     name = "find",
--     f = { "<cmd>Telescope find_files<cr>", "Find File" },
--     b = { "<cmd>Telescope buffers<cr>", "Find Buffers" },
--     r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
--     g = { "<cmd>Telescope live_grep<cr>", "Grep File" },
--     n = { "<cmd>:new<cr>", "New File" },
--   },
--   j = {
--     name = "jump",
--     w = { "<cmd>HopWord<cr>", "Jump Word" },
--     j = { "<cmd>HopChar1<cr>", "Jump Char" },
--   },
--   l = {
--     name = "LSP",
--     i = { "<cmd>LspInstallInfo<cr>", "Install LanguageServer" },
--     f = { "<cmd>lua vim.lsp.buf.format({async = true})<cr>", "Format" },
--   },
--   w = { "<cmd>:w<cr>", "Write File" },
--   x = { "<cmd>:x<cr>", "Write And Close File" },
--   q = { "<cmd>:q<cr>", "Close File" },
--   e = { "<cmd>:NvimTreeToggle<cr>", "Toggle File Explorer" },
--
-- }

-- local vopts = {
--   mode = "v", -- VISUAL mode
--   prefix = "<leader>",
--   buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
--   silent = true, -- use `silent` when creating keymaps
--   noremap = true, -- use `noremap` when creating keymaps
--   nowait = true, -- use `nowait` when creating keymaps
-- }
-- local vmappings = {
--   ["/"] = { "<ESC><CMD>lua require(\"Comment.api\").toggle_linewise_op(vim.fn.visualmode())<CR>", "Comment" },
-- }
--
which_key.setup(setup)
-- which_key.register(mappings, opts)
which_key.add(mappings)
-- which_key.register(vmappings, vopts)
