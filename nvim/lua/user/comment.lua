local status_ok, comment = pcall(require, "Comment")
if not status_ok then
  print("Comment not found")
  return
end

comment.setup()
