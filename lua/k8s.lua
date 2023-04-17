local api = require("k8s.api")
local commands = require("k8s.commands")
local kube_config = require("k8s.kube_config")
local global_contexts = require("k8s.global_contexts")

local M = {}

M.config = {
    kube_config = {
        location = "~/.kube/config",
    },
}

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

    api.setup(M.config)
    commands.setup(M.config)
    kube_config.setup(M.config)
    global_contexts.setup(M.config)
end

return M
