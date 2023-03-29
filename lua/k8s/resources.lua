local context = require("k8s.resources.context")

local M = {}

M.setup = function(config)
    context.setup(config)
end

return M
