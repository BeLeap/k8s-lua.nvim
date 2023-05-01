local M = {
  kube_config = {
    location = "~/.kube/config",
  },
  resources = {
    pod = {
      log = {
        max_lines = 1000,
      },
    },
  },
}

M.setup = function(user_config)
  M = vim.tbl_deep_extend("force", M, user_config or {})
end

return M
