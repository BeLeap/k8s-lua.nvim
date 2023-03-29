local commands = require("k8s.commands")
local kube_config = require("k8s.kube_config")
local resources = require("k8s.resources")

local M = {}

M.config = {
    kube_config = {
        location = "~/.kube/config",
    },
}

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

    commands.setup(M.config)
    kube_config.setup(M.config)
    resources.setup(M.config)
end

return M
