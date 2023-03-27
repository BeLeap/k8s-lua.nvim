local utils = require("k8s.utils")
local constants = require("k8s.constants")

local M = {}

M.read_config = function()
	local content = utils.readfile(constants.kubeconfig)
	print(content)
end

return M
