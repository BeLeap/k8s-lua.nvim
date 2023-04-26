local context = require("k8s.resources.context")

---@class GlobalContext
---@field selected_contexts string|nil
---@field selected_namespace string
---@field ns_id NamespaceId
local GlobalContext = {
  ns_id = vim.api.nvim_create_namespace("kubernetes"),
}

GlobalContext.setup = function()
  GlobalContext.selected_contexts = context.get_current()
end

return GlobalContext
