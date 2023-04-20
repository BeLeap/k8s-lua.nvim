local pickers = require("k8s.ui.pickers")
local resources = require("k8s.resources")
local global_contexts = require("k8s.global_contexts")

local M = {}

M.select = function()
    local pods = resources:new("pods", "api/v1", true, global_contexts.selected_namepace)
    local Picker = pickers:new(pods, {})
    Picker.picker:find()
end

return M
