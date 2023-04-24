local context = require("k8s.resources.context")

---@class GlobalContext
---@field selected_contexts string|nil
---@field selected_namespace string
local GlobalContext = {
    ns_id = vim.api.nvim_create_namespace("kubernetes"),
}

GlobalContext.setup = function(_config)
    GlobalContext.selected_contexts = context.get_current()
end

return GlobalContext
