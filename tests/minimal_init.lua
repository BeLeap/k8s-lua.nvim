local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local plenary_not_exists = vim.fn.isdirectory(plenary_dir) == 0
if plenary_not_exists then
  vim.fn.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_dir })
end

vim.opt.runtimepath:append(".")
vim.opt.runtimepath:append(plenary_dir)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
