local context = require("k8s.context")

local M = {
	commands = {
		{
			name = "K8sContextSelect",
			opts = {
				desc = "select target context",
			},
			command = function()
				context.select_context()
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
