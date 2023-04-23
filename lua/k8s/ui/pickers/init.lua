local utils = require("k8s.utils")

---@class ResourceEntry
---@field value KubernetesObject
---@field display string
---@field ordinal string

---@class ResourcesPicker
---@field private resources Resource
---@field public buffer BufferHandle
local M = {}

---@param resources Resource
---@param args { on_select: fun(selection: string)|nil, is_current: fun(name: string): boolean | nil }
function M.new(resources, args)
    local objects = resources:list()

    if objects ~= nil then
        local buffer = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_buf_set_option(buffer, "buftype", "")
        vim.api.nvim_buf_set_name(buffer, "k8s://" .. resources.kind)

        local namespace = vim.api.nvim_create_namespace("kubernetes")

        for index, object in ipairs(objects) do
            vim.api.nvim_buf_set_lines(buffer, index - 1, index, false, { object.metadata.name })

            if args.is_current ~= nil and args.is_current(object.metadata.name) then
                vim.api.nvim_buf_set_extmark(buffer, namespace, index - 1, -1, {
                    virt_text = {
                        { "current", "Comment" },
                    },
                })
            end
        end

        vim.api.nvim_buf_set_option(buffer, "modifiable", false)

        ---set keymap for picker buffer
        ---@param mode string
        ---@param key string
        ---@param action function
        ---@param opts {}
        local local_keymap = function(mode, key, action, opts)
            local opts_with_buf = vim.tbl_deep_extend("keep", opts, { buffer = buffer })

            vim.keymap.set(mode, key, action, opts_with_buf)
        end

        local_keymap("n", "e", function()
            local on = utils.line_under_cursor()
            local object = resources:get(on)

            if object ~= nil then
                local edit_buffer = vim.api.nvim_create_buf(true, true)
                vim.api.nvim_buf_set_name(edit_buffer, "k8s://" .. resources.kind .. "/" .. on)
                vim.api.nvim_buf_set_option(edit_buffer, "buftype", "")
                vim.api.nvim_buf_set_option(edit_buffer, "ft", "lua")
                vim.api.nvim_buf_set_lines(edit_buffer, 0, -1, false, vim.fn.split(tostring(vim.inspect(object)), "\n"))

                vim.api.nvim_buf_attach(edit_buffer, false, {})
                vim.api.nvim_set_current_buf(edit_buffer)

                vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
                    buffer = edit_buffer,
                    callback = function(ev)
                        local content_raw = utils.join_to_string(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
                        local content = load("return " .. content_raw)()
                        local diff = utils.calculate_diffs(object, content)

                        self.resources:patch(object.metadata, vim.json.encode(diff))
                        vim.api.nvim_buf_delete(edit_buffer, { force = true })
                    end,
                })
            else
                print("got nil")
            end
        end, {})

        if args.on_select ~= nil then
            local_keymap("n", "s", function()
                local on = utils.line_under_cursor()
                args.on_select(on)

                vim.api.nvim_buf_delete(buffer, { force = true })
            end, {})
        end

        vim.api.nvim_buf_attach(buffer, false, {})
        vim.api.nvim_set_current_buf(buffer)
    else
        print("got nil")
    end
end

return M
