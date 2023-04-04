local ui_context = require("k8s.ui.context")
local ui_namespace = require("k8s.ui.namespace")

local M = {
    commands = {
        {
            name = "K8sContextSelect",
            opts = {
                desc = "select target context",
            },
            command = function()
                ui_context.select()
            end,
        },
        {
            name = "K8sNamespaceSelect",
            opts = {},
            command = function()
                ui_namespace.select()
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
