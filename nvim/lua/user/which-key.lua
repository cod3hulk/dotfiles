local wk = require("which-key")

wk.register({
  f = {
    name = "find", 
    f = { "<cmd>Telescope find_files<cr>", "Find File" }, 
    b = { "<cmd>Telescope buffers<cr>", "Find Buffers" }, 
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File"}, 
    g = { "<cmd>Telescope live_grep<cr>", "Grep File"}, 
    n = { "<cmd>:new<cr>", "New File" }, 
  },
  w = { "<cmd>:w<cr>", "Write File" },
  x = { "<cmd>:x<cr>", "Write And Close File" },
  q = { "<cmd>:q<cr>", "Close File" }
}, { prefix = "<leader>" })