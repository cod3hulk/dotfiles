local status_ok, mason = pcall(require, "mason")
if not status_ok then
  print "unable to load mason"
  return
end

local status_ok_1, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok_1 then
  print "unable to load mason-lspconfig"
  return
end

local servers = {
  "lua_ls",
  "tsserver",
  "jsonls"
}

mason.setup()

mason_lspconfig.setup {
  ensure_installed = servers,
  automatic_installation = true,
}

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  print "unable to lspconfig"
  return
end

local opts = {}

for _, server in pairs(servers) do
  opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }

  server = vim.split(server, "@")[1]


  if server == "lua_ls" then
    local lusls_opts = require("user.lsp.settings.lua_ls")
    opts = vim.tbl_deep_extend("force", lusls_opts, opts)
  end
  if server == "jsonls" then
    local jsonls = require("user.lsp.settings.jsonls")
    opts = vim.tbl_deep_extend("force", jsonls, opts)
  end


  lspconfig[server].setup(opts)
end
