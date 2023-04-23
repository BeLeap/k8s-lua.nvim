local pickers = require("k8s.ui.pickers")
local resources = require("k8s.resources")
local global_contexts = require("k8s.global_contexts")

local M = {}

M.select = function()
    local deployments = resources:new("deployments", "apis/apps/v1", true, global_contexts.selected_namepace)
    pickers.new(deployments, {})
end

return M
