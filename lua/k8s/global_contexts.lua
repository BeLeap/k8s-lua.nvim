local context = require("k8s.resources.context")

---@class GlobalContext
---@field selected_contexts string|nil
---@field selected_namespace string
---@field ns_id NamespaceId
local GlobalContext = {
  ns_id = vim.api.nvim_create_namespace("kubernetes"),
}

GlobalContext.setup = function()
  local current_context = context.get_current()
  if current_context == nil then
    current_context = context.list()[0]
  end
  GlobalContext.selected_contexts = current_context
end

return GlobalContext
