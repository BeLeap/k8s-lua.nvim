local utils = require("k8s.utils")

local M = {}

M.read_config = function()
	local home = os.getenv("HOME")

	local content = utils.readfile(home .. "/.kube/config")
	print(content)
end

return M
