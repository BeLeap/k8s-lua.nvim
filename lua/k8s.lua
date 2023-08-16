local commands = require("k8s.commands")
local config = require("k8s.config")
local global_contexts = require("k8s.global_contexts")
local highlight = require("k8s.highlight")

local notify_exists, notify = pcall(require, "notify")
if notify_exists then
  vim.notify = notify
end

local M = {}

M.config = {
  resources = {
    pod = {
      log = {
        max_lines = 1000,
      },
    },
  },
}

M.setup = function(user_config)
  config.setup(user_config)
  global_contexts.setup()

  commands.setup()
  highlight.setup()
end

return M
