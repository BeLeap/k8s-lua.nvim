local resources_namespace = require("k8s.resources.namespace")
local pickers = require("k8s.ui.pickers")

local M = {}

M.select = function()
    local picker = pickers.new({
        kind = "namespaces",
        resources = resources_namespace,
        when_select = function(selection)
            resources_namespace.current_name = selection.value.metadata.name
        end,
        is_current = function(entry)
            if entry.metadata.name == resources_namespace.current_name then
                return true
            end

            return false
        end,
    })

    picker:find()
end

return M
