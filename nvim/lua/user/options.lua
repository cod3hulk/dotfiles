local opts = {
  backup = false,
  clipboard ='unnamedplus',
  completeopt = { "menuone", "noselect" }, 
  cursorline = true,
  expandtab = true,
  fileencoding = "utf-8",
  hls = true,
  incsearch = true,
  number = true,
  relativenumber = true,
  scrolloff = 10,
  shiftwidth = 2,
  signcolumn = "yes",
  smartcase = true,
  smarttab = true,
  splitbelow = true,
  splitright = true,
  swapfile = false,
  tabstop = 2,
  undofile = true,
  wrap = false,
  writebackup = false,
}

for k, v in pairs(opts) do
  vim.opt[k] = v
end

