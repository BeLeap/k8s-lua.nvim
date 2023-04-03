local resources_context = require("k8s.resources.context")
local resources_namespace = require("k8s.resources.namespace")

local M = {
    commands = {
        {
            name = "K8sContextSelect",
            opts = {
                desc = "select target context",
            },
            command = function()
                resources_context.select_context()
            end,
        },
        {
            name = "K8sNamespaceSelect",
            opts = {},
            command = function()
                resources_namespace.select()
            end,
        },
    },
}

M.setup = function(_config)
    for _, command in ipairs(M.commands) do
        local opts = vim.tbl_extend("force", command.opts, { force = true })
        vim.api.nvim_create_user_command(command.name, command.command, opts)
    end
end

return M
