local M = {}

M.setup = function()
  vim.api.nvim_set_hl(0, "K8sPodUnhealthy", {
    fg = "red",
    ctermfg = "red",
  })
end

return M
