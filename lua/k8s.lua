local M = {}

M.config = {
  kubeconfig_location = "~/.kube/config"
}

M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

return M
