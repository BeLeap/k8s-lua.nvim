local resources_namespace = require("k8s.resources.namespace")

local resource_pickers = require("k8s.ui.resource_pickers")

local M = {}

M.select = function()
    local picker = resource_pickers.new({
        kind = "Namespaces",
        resources = resources_namespace,
        when_select = function(selection)
            resources_namespace.target = selection.value.metadata.name
        end,
    })

    picker:find()
end

return M
