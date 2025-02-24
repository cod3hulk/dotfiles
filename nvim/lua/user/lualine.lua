local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  print("lualine not found")
  return
end

lualine.setup()
