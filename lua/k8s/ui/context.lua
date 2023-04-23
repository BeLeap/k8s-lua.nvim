local global_contexts = require("k8s.global_contexts")
local resources_context = require("k8s.resources.context")
local pickers = require("k8s.ui.pickers")

local M = {}

-- select context with telescope picker
M.select = function()
    pickers.new(resources_context, {
        on_select = function(selection)
            global_contexts.selected_contexts = selection
        end,
        is_current = function(name)
            return name == global_contexts.selected_contexts
        end,
    })
end

return M
