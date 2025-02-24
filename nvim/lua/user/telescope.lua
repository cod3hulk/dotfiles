local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  print("telescope not found")
  return
end

local actions = require("telescope.actions")
local setup = {
  pickers = {
    git_branches = {
      mappings = {
        i = {
          ["<CR>"] =  actions.git_switch_branch
        }
      }
    }
  }
}

telescope.setup(setup)
