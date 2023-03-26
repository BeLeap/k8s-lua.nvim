local M = {}

local function read_config()
	for line in vim.api.readfile("~/.kube/config") do
		print(line)
	end
end

return M
