local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
end

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }

  if server.name == "lua_ls" then
    local luals_opts = require("user.lsp.settings.lua_ls")
    opts = vim.tbl_deep_extend("force", luals_opts, opts)
  end

  if server.name == "tsserver" then
    local tsserver_opts = {}
    opts = vim.tbl_deep_extend("force", tsserver_opts, opts)
  end
  --
  -- if server.name == "pyright" then
  --   local pyright_opts = require("user.lsp.settings.pyright")
  --   opts = vim.tbl_deep_extend("force", pyright_opts, opts)
  -- end
  --
  -- This setup() function is exactly the same as lspconfig's setup function.
  -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  server:setup(opts)
end)

