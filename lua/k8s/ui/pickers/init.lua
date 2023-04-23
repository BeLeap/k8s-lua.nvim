local utils = require("k8s.utils")
local buffer = require("k8s.ui.buffer")

---@class ResourceEntry
---@field value KubernetesObject
---@field display string
---@field ordinal string

---@class ResourcesPicker
---@field private resources Resources
---@field public buffer BufferHandle
local M = {}

---@param resources Resources
---@param args { on_select: (fun(selection: string) | nil), is_current: ((fun(name: string): boolean) | nil), editable: (boolean | nil) }
function M.new(resources, args)
    local objects = resources:list()

    if objects ~= nil then
        local Buffer = buffer:new()
        Buffer:vim_api("nvim_buf_set_option", "buftype", "")
        Buffer:vim_api("nvim_buf_set_name", "k8s://" .. resources.kind)

        local namespace = vim.api.nvim_create_namespace("kubernetes")

        for index, object in ipairs(objects) do
            Buffer:vim_api("nvim_buf_set_lines", index - 1, index, false, { object.metadata.name })

            if args.is_current ~= nil and args.is_current(object.metadata.name) then
                Buffer:vim_api("nvim_buf_set_extmark", namespace, index - 1, -1, {
                    virt_text = {
                        { "current", "Comment" },
                    },
                })
            end
        end

        Buffer:vim_api("nvim_buf_set_option", "modifiable", false)

        ---set keymap for picker buffer
        ---@param mode string
        ---@param key string
        ---@param action function
        ---@param opts {}
        local local_keymap = function(mode, key, action, opts)
            local opts_with_buf = vim.tbl_deep_extend("keep", opts, { buffer = Buffer.buffer })

            vim.keymap.set(mode, key, action, opts_with_buf)
        end

        local_keymap("n", "e", function()
            if args.editable ~= false then
                local on = Buffer:line_under_cursor()
                local object = resources:get(on)

                if object ~= nil then
                    local edit_buffer = vim.api.nvim_create_buf(true, true)
                    EditBuffer = buffer:new()
                    EditBuffer:vim_api("nvim_buf_set_name", "k8s://" .. resources.kind .. "/" .. on)
                    EditBuffer:vim_api("nvim_buf_set_option", "buftype", "")
                    EditBuffer:vim_api("nvim_buf_set_option", "ft", "lua")
                    EditBuffer:vim_api(
                        "nvim_buf_set_lines",
                        0,
                        -1,
                        false,
                        vim.fn.split(tostring(vim.inspect(object)), "\n")
                    )

                    EditBuffer:vim_api("nvim_buf_attach", false, {})
                    EditBuffer:vim_api("nvim_set_current_buf")

                    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
                        buffer = edit_buffer,
                        callback = function(ev)
                            local content_raw = utils.join_to_string(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
                            local content = load("return " .. content_raw)()
                            local diff = utils.calculate_diffs(object, content)

                            resources:patch(object.metadata, vim.json.encode(diff))
                            vim.api.nvim_buf_delete(edit_buffer, { force = true })
                        end,
                    })
                else
                    print("Empty get resource request: " .. resources.kind .. "/" .. on)
                end
            else
                print("Uneditable Resource: " .. resources.kind)
            end
        end, {})

        local_keymap("n", "s", function()
            if args.on_select ~= nil then
                local on = Buffer:line_under_cursor()
                args.on_select(on)

                Buffer:vim_api("nvim_buf_delete", { force = true })
            else
                print("Unselectable Resource: " .. resources.kind)
            end
        end, {})

        Buffer:vim_api("nvim_buf_attach", false, {})
        Buffer:vim_api("nvim_set_current_buf")
    else
        print("Empty list resource request: " .. resources.kind)
    end
end

return M
