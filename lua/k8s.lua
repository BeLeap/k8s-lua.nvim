local context = require("k8s.context")
local commands = require("k8s.commands")

local M = {}

M.config = {
  context = {
    location = "~/.kube/config",
  },
}

M.setup = function(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

  context.setup(M.config)
  commands.setup(M.config)
end

return M
