local resources = require("k8s.resources")
local global_contexts = require("k8s.global_contexts")
local NamespaceResourcePicker = require("k8s.ui.pickers.namespaced")

local M = {}

M.select = function()
  local deployments = resources:new("deployments", "apps/v1", true, global_contexts.selected_namespace)

  NamespaceResourcePicker:new(deployments, {
    entry_modifier = function(buffer, index, object)
      local deployment = object --[[@as Deployment]]

      buffer:vim_api("nvim_buf_set_extmark", global_contexts.ns_id, index - 1, -1, {
        virt_text = {
          {
            tostring(deployment.status.readyReplicas) .. "/" .. tostring(deployment.status.replicas),
            "Comment",
          },
        },
      })
    end,
  })
end

return M
