local M = {
    commands = {
        {
            name = "Kube",
            opts = {
                nargs = "*",
                complete = function(arglead, line)
                    return { "context", "namespace", "pod", "deployment", "statefulset" }
                end,
            },
            command = function(opts)
                local ui = require("k8s.ui." .. opts.args)
                ui.select()
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
