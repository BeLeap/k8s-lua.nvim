local pickers = require("k8s.ui.pickers")
local global_contexts = require("k8s.global_contexts")
local resources = require("k8s.resources")

local M = {}

M.select = function()
    local namespace = resources:new("namespaces", "api/v1", false, nil)
    local Picker = pickers:new(namespace, {
        when_select = function(selection)
            global_contexts.selected_namepace = selection.value.metadata.name
        end,
        is_current = function(entry)
            if entry.metadata.name == global_contexts.selected_namepace then
                return true
            end

            return false
        end,
    })

    Picker.picker:find()
end

return M
