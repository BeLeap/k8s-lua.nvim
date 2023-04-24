local M = {
    commands = {
        {
            name = "Kube",
            opts = {
                nargs = "*",
                complete = function(arglead, _line)
                    local resources = { "context", "namespace", "pod", "deployment", "statefulset", "service" }

                    local match = {}
                    if arglead ~= nil then
                        for _, resource in ipairs(resources) do
                            if vim.startswith(resource, arglead) then
                                table.insert(match, resource)
                            end
                        end
                    else
                        match = resources
                    end

                    return match
                end,
            },
            command = function(opts)
                if opts.args == "" then
                    print("k8s-lua.nvim: argument required!")
                    return
                end

                local ui = require("k8s.ui." .. opts.args)
                ui.select()
            end,
        },
    },
}

M.setup = function()
    for _, command in ipairs(M.commands) do
        local opts = vim.tbl_extend("force", command.opts, { force = true })
        vim.api.nvim_create_user_command(command.name, command.command, opts)
    end
end

return M
