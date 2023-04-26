local commands = require("k8s.commands")
local kube_config = require("k8s.kube_config")
local global_contexts = require("k8s.global_contexts")
local highlight = require("k8s.highlight")

local notify_exists, notify = pcall(require, "notify")
if notify_exists then
  vim.notify = notify
end

local M = {}

M.config = {
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
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

  kube_config.setup(M.config)
  global_contexts.setup()

  commands.setup()
  highlight.setup()
end

return M
