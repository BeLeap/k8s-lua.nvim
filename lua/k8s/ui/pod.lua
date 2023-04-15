local pickers = require("k8s.ui.pickers")
local NamespacedResource = require("k8s.resources.namespaced")

local M = {}

M.select = function()
    local pods = NamespacedResource:new("pods")
    local Picker = pickers:new(pods)
    Picker.picker:find()
end

return M
