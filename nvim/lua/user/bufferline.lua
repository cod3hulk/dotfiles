local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

bufferline.setup({
  options = {
    numbers = "none",
    close_command = "bdelete! %d",
    right_mouse_command = "bdelete! %d",
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(_, _, diagnostics_dict)
      local s = " "
      for e, n in pairs(diagnostics_dict) do
        local sym = e == "error" and " " or (e == "warning" and " " or "")
        s = s .. n .. sym
      end
      return s
    end,
    offsets = {
      { filetype = "NvimTree", text = "Files", padding = 1 },
    },
    show_buffer_close_icons = true,
    show_close_icon = false,
    separator_style = "thin",
  },
})

-- Cycle buffers
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { silent = true })
