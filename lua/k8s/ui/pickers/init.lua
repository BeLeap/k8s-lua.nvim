local utils = require("k8s.utils")
local buffer = require("k8s.ui.buffer")

---@class ResourceEntry
---@field value KubernetesObject
---@field display string
---@field ordinal string

---@class ResourcePicker
---@field public resources Resources
---@field public objects KubernetesObject[]|nil
---@field public buffer Buffer|nil
local ResourcePicker = {}

---@class PickerNewArgs
---@field on_select (fun(selection: KubernetesObjectMeta) | nil)
---@field editable (boolean | nil)
---@field entry_modifier (fun(buffer: Buffer, index: integer, object: KubernetesObject) | nil)
---@field additional_keymaps (AdditionalKeymap[] | nil)

---@class AdditionalKeymap
---@field mode
---| "n"
---| "i"
---| "v"
---@field key string
---@field action fun(picker: ResourcePicker): function
---@field opts table|nil

---@param resources Resources
---@param args PickerNewArgs
function ResourcePicker:new(resources, args)
    local o = {}
    o = vim.deepcopy(self)

    o.resources = resources
    o.objects = resources:list()

    if o.objects ~= nil then
        o.buffer = buffer:new()
        o.buffer:vim_api("nvim_buf_set_option", "buftype", "")
        o.buffer:vim_api("nvim_buf_set_name", "k8s://" .. resources.kind)

        for index, object in ipairs(o.objects) do
            o.buffer:vim_api("nvim_buf_set_lines", index - 1, index, false, { object.metadata.name })

            if args.entry_modifier then
                args.entry_modifier(o.buffer, index, object)
            end
        end

        o.buffer:vim_api("nvim_buf_set_option", "modifiable", false)

        o.buffer:keymap("n", "e", function()
            if args.editable ~= false then
                local cursor_location = vim.api.nvim_win_get_cursor(0)
                local object = o.objects[cursor_location[1]]

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

                o.buffer:vim_api("nvim_buf_delete", { force = true })

                EditBuffer:create_autocmd({ "BufWriteCmd" }, {
                    callback = function(ev)
                        local content_raw = utils.join_to_string(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
                        local content = load("return " .. content_raw)()
                        local diff = utils.calculate_diffs(object, content)

                        resources:patch(object.metadata, vim.json.encode(diff))
                        EditBuffer:vim_api("nvim_buf_delete", { force = true })
                    end,
                })
            else
                print("Uneditable Resource: " .. resources.kind)
            end
        end)

        o.buffer:keymap("n", "s", function()
            if args.on_select ~= nil then
                local cursor_location = vim.api.nvim_win_get_cursor(0)
                local object = o.objects[cursor_location[1]]

                args.on_select(object.metadata)

                o.buffer:vim_api("nvim_buf_delete", { force = true })
            else
                print("Unselectable Resource: " .. resources.kind)
            end
        end)

        o.buffer:keymap("n", "r", function()
            o.buffer:vim_api("nvim_buf_delete", { force = true })
            ResourcePicker:new(resources, args)
        end)

        if args.additional_keymaps ~= nil then
            for _, v in ipairs(args.additional_keymaps) do
                o.buffer:keymap(v.mode, v.key, v.action(o), v.opts)
            end
        end

        o.buffer:vim_api("nvim_set_current_buf")
    else
        print("Empty list resource request: " .. resources.kind)
    end

    return o
end

return ResourcePicker
