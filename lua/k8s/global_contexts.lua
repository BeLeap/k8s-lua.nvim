local context = require("k8s.resources.context")
---@class GlobalContext
---@field selected_contexts string|nil
---@field selected_namepace string
local GlobalContext = {}

GlobalContext.setup = function(_config)
    GlobalContext.selected_contexts = context.get_current()
end

return GlobalContext
