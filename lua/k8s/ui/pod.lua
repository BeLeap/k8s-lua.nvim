local pickers = require("k8s.ui.pickers")
local resources = require("k8s.resources")
local global_contexts = require("k8s.global_contexts")

local M = {}

M.select = function()
    local pods = resources:new("pods", "api/v1", true, global_contexts.selected_namespace)
    pickers.new(pods, {
        entry_modifier = function(buffer, index, object)
            local pod = object --[[@as Pod]]

            buffer:vim_api("nvim_buf_set_extmark", global_contexts.ns_id, index - 1, -1, {
                virt_text = {
                    { pod.status.phase, "Comment" },
                },
            })

            local conditions = pod.status.conditions

            for _, condition in ipairs(conditions) do
                if condition.type == "ContainersReady" and condition.status == "False" then
                    buffer:highlight(global_contexts.ns_id, "K8sPodUnhealthy", { index - 1, 0 }, { index - 1, -1 })
                end
            end
        end,
    })
end

return M
