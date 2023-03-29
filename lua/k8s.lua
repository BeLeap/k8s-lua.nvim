local M = {}

M.config = {
  kubeconfig_location = os.getenv("HOME") .. "/.kube/config"
}

M.setup = function(args)
  if args.kubeconfig_location ~= nil then
    args.kubeconfig_location = vim.fs.normalize(args.kubeconfig_location)
  end

  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

return M
