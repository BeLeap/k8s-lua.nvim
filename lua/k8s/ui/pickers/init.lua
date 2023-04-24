local utils = require("k8s.utils")
local buffer = require("k8s.ui.buffer")
local global_contexts = require("k8s.global_contexts")

---@class ResourceEntry
---@field value KubernetesObject
---@field display string
---@field ordinal string

local M = {}

---@param resources Resources
---@param args { on_select: (fun(selection: KubernetesObjectMeta) | nil), editable: (boolean | nil), entry_modifier: (fun(buffer: Buffer, index: integer, object: KubernetesObject) | nil) }
function M.new(resources, args)
    local objects = resources:list()

    if objects ~= nil then
        local Buffer = buffer:new()
        Buffer:vim_api("nvim_buf_set_option", "buftype", "")
        Buffer:vim_api("nvim_buf_set_name", "k8s://" .. resources.kind)

        for index, object in ipairs(objects) do
            Buffer:vim_api("nvim_buf_set_lines", index - 1, index, false, { object.metadata.name })

            if args.entry_modifier then
                args.entry_modifier(Buffer, index, object)
            end
        end

        Buffer:vim_api("nvim_buf_set_option", "modifiable", false)

        Buffer:keymap("n", "e", function()
            if args.editable ~= false then
                local cursor_location = vim.api.nvim_win_get_cursor(0)
                local object = objects[cursor_location[1]]

                EditBuffer = buffer:new()
                EditBuffer:vim_api("nvim_buf_set_name", "k8s://" .. resources.kind .. "/" .. object.metadata.name)
                EditBuffer:vim_api("nvim_buf_set_option", "buftype", "")
                EditBuffer:vim_api("nvim_buf_set_option", "ft", "lua")
                EditBuffer:vim_api(
                    "nvim_buf_set_lines",
                    0,
                    -1,
                    false,
                    vim.fn.split(tostring(vim.inspect(object)), "\n")
                )

                EditBuffer:vim_api("nvim_set_current_buf")
                Buffer:vim_api("nvim_buf_delete", { force = true })

                vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
                    buffer = EditBuffer.buffer,
                    callback = function(ev)
                        local content_raw = utils.join_to_string(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
                        local content = load("return " .. content_raw)()
                        local diff = utils.calculate_diffs(object, content)

                        resources:patch(object.metadata, vim.json.encode(diff))
                        EditBuffer:vim_api("nvim_buf_delete", { force = true })

                        M.new(resources, args)
                    end,
                })
            else
                print("Uneditable Resource: " .. resources.kind)
            end
        end)

        Buffer:keymap("n", "s", function()
            if args.on_select ~= nil then
                local cursor_location = vim.api.nvim_win_get_cursor(0)
                local object = objects[cursor_location[1]]

                args.on_select(object.metadata)

                Buffer:vim_api("nvim_buf_delete", { force = true })
            else
                print("Unselectable Resource: " .. resources.kind)
            end
        end)

        Buffer:keymap("n", "q", function()
            Buffer:vim_api("nvim_buf_delete", { force = true })
        end)

        Buffer:keymap("n", "r", function()
            Buffer:vim_api("nvim_buf_delete", { force = true })
            M.new(resources, args)
        end)

        Buffer:vim_api("nvim_set_current_buf")
    else
        print("Empty list resource request: " .. resources.kind)
    end
end

return M
