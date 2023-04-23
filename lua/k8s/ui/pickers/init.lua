local utils = require("k8s.utils")

---@class ResourceEntry
---@field value KubernetesObject
---@field display string
---@field ordinal string

---@class ResourcesPicker
---@field private resources Resource
---@field public buffer BufferHandle
local ResourcesPicker = {}

---@param resources Resource
---@param args { on_select: fun(selection: string): nil|nil }
function ResourcesPicker:new(resources, args)
    self.resources = resources

    local iter = self.resources:list_iter()

    if iter ~= nil then
        local names = iter:map(
            ---@param elem KubernetesObject
            function(elem)
                return elem.metadata.name
            end
        ):tolist()

        self.buffer = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_buf_set_name(self.buffer, "k8s://" .. self.resources.kind)
        vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, names)

        vim.api.nvim_buf_set_option(self.buffer, "buftype", "")
        vim.api.nvim_buf_set_option(self.buffer, "modifiable", false)

        ---set keymap for picker buffer
        ---@param mode string
        ---@param key string
        ---@param action function
        ---@param opts {}
        local local_keymap = function(mode, key, action, opts)
            local opts_with_buf = vim.tbl_deep_extend("keep", opts, { buffer = self.buffer })

            vim.keymap.set(mode, key, action, opts_with_buf)
        end

        local_keymap("n", "e", function()
            local on = utils.line_under_cursor()
            local object = self.resources:get(on)

            if object ~= nil then
                local buffer = vim.api.nvim_create_buf(true, true)
                vim.api.nvim_buf_set_name(buffer, "k8s://" .. self.resources.kind .. "/" .. on)
                vim.api.nvim_buf_set_option(buffer, "buftype", "")
                vim.api.nvim_buf_set_option(buffer, "ft", "lua")
                vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.fn.split(tostring(vim.inspect(object)), "\n"))

                vim.api.nvim_buf_attach(buffer, false, {})
                vim.api.nvim_set_current_buf(buffer)

                vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
                    buffer = buffer,
                    callback = function(ev)
                        local content_raw = utils.join_to_string(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
                        local content = load("return " .. content_raw)()
                        local diff = utils.calculate_diffs(object, content)

                        self.resources:patch(object.metadata, vim.json.encode(diff))
                        vim.api.nvim_buf_delete(buffer, { force = true })
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

                vim.api.nvim_buf_delete(self.buffer, { force = true })
            end, {})
        end
    else
        print("got nil")
    end

    vim.api.nvim_buf_attach(self.buffer, false, {})
    vim.api.nvim_set_current_buf(self.buffer)

    return self
end

return ResourcesPicker
