local proxy = require("k8s.api.proxy")

local M = {}

M.setup = function(config)
    proxy.setup(config)
end

return M
