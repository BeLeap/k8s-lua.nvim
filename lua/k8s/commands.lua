local ui_context = require("k8s.ui.context")
local ui_namespace = require("k8s.ui.namespace")
local ui_pod = require("k8s.ui.pod")
local ui_deployment = require("k8s.ui.deployment")

local M = {
    commands = {
        {
            name = "KubeContextSelect",
            opts = {
                desc = "select target context",
            },
            command = function()
                ui_context.select()
            end,
        },
        {
            name = "KubeNamespaceSelect",
            opts = {},
            command = function()
                ui_namespace.select()
            end,
        },
        {
            name = "KubePodList",
            opts = {},
            command = function()
                ui_pod.select()
            end,
        },
        {
            name = "KubeDeploymentList",
            opts = {},
            command = function()
                ui_deployment.select()
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
