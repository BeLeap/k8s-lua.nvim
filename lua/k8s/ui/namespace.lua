local pickers = require("k8s.ui.pickers")
local resources = require("k8s.resources")
local global_contexts = require("k8s.global_contexts")

local M = {}

M.select = function()
    local namespace = resources:new("namespaces", "api/v1", false, nil)
    pickers.new(namespace, {
        on_select = function(selection)
            global_contexts.selected_namepace = selection.name
        end,
        is_current = function(metadata)
            return metadata.name == global_contexts.selected_namepace
        end,
    })
end

return M
