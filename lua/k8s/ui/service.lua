local pickers = require("k8s.ui.pickers")
local resources = require("k8s.resources")
local global_contexts = require("k8s.global_contexts")

local M = {}

M.select = function()
  local statefulsets = resources:new("services", "api", "v1", true, global_contexts.selected_namespace)
  pickers:new(statefulsets, {})
end

return M
