local resources = require("k8s.resources")
local global_contexts = require("k8s.global_contexts")
local NamespacedResourcePicker = require("k8s.ui.pickers.namespaced")

local M = {}

M.select = function()
  local statefulsets = resources:new("statefulsets", "apps/v1", true, global_contexts.selected_namespace)
  NamespacedResourcePicker:new(statefulsets, {})
end

return M
