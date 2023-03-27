local M = {}

M.home = os.getenv("HOME")
M.kubeconfig = M.home .. "/.kube/config"

return M
