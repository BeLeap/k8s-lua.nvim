local resources_pod = require("k8s.resources.pod")
local resource_pickers = require("k8s.ui.resource_pickers")

local M = {}

M.select = function()
    local picker = resource_pickers.new({
        kind = "Pods",
        resources = resources_pod,
    })
    picker:find()
end

return M
