local pickers = require("k8s.ui.pickers")
local buffer = require("k8s.ui.buffer")
local resources = require("k8s.resources.pod")
local global_contexts = require("k8s.global_contexts")

local M = {}

M.select = function()
    local pods = resources:new("pods", "api", "v1", true, global_contexts.selected_namespace)

    pickers:new(pods, {
        entry_modifier = function(picker_buffer, index, object)
            local pod = object --[[@as Pod]]

            picker_buffer:vim_api("nvim_buf_set_extmark", global_contexts.ns_id, index - 1, -1, {
                virt_text = {
                    { pod.status.phase, "Comment" },
                },
            })

            local conditions = pod.status.conditions

            for _, condition in ipairs(conditions) do
                if condition.type == "ContainersReady" and condition.status == "False" then
                    picker_buffer:highlight(
                        global_contexts.ns_id,
                        "K8sPodUnhealthy",
                        { index - 1, 0 },
                        { index - 1, -1 }
                    )
                end
            end
        end,
        additional_keymaps = {
            {
                mode = "n",
                key = "l",
                action = function(picker)
                    return function()
                        local cursor_location = vim.api.nvim_win_get_cursor(0)
                        local object = picker.objects[cursor_location[1]] --[[@as Pod]]
                        local logs = pods:get_log(object)

                        for k, v in pairs(logs) do
                            local LogBuffer = buffer:new(
                                "k8s://"
                                    .. pods:build_fqdn(object.metadata.namespace)
                                    .. "/"
                                    .. object.metadata.name
                                    .. "/log/"
                                    .. k
                            )

                            LogBuffer:vim_api("nvim_buf_set_option", "buftype", "")
                            LogBuffer:vim_api("nvim_buf_set_option", "ft", "log")

                            ---@type string[]
                            local lines = vim.fn.split(v, "\n")

                            LogBuffer:vim_api("nvim_buf_set_lines", 0, -1, false, lines)

                            vim.cmd.split(LogBuffer.name)
                            vim.api.nvim_win_set_cursor(0, { #lines, 0 })
                        end
                    end
                end,
            },
        },
    })
end

return M
