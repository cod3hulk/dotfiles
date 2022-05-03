local status_ok, hop = pcall(require, "hop")
if not status_ok then
  print("hop not found")
  return
end

hop.setup({
  keys = "abcdefghijklmnopqrstuvwxyz"
})
