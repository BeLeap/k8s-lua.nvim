local pickers = require("k8s.ui.pickers")
local resources = require("k8s.resources")
local global_contexts = require("k8s.global_contexts")

local M = {}

M.select = function()
    local namespace = resources:new("namespaces", "api/v1", false, nil)
    pickers.new(namespace, {
        on_select = function(selection)
            global_contexts.selected_namespace = selection.name
        end,
        entry_modifier = function(buffer, index, object)
            if object.metadata.name == global_contexts.selected_namespace then
                buffer:vim_api("nvim_buf_set_extmark", global_contexts.ns_id, index - 1, -1, {
                    virt_text = {
                        { "current", "Comment" },
                    },
                })
            end
        end,
    })
end

return M
