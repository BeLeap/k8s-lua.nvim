local resources_pod = require("k8s.resources.pod")
local pickers = require("k8s.ui.pickers")

local M = {}

M.select = function()
    local picker = pickers.new({
        kind = "pods",
        resources = resources_pod,
    })
    picker:find()
end

return M
