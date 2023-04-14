local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

local utils = require("k8s.utils")
local detail = require("k8s.ui.pickers.detail")

local M = {}

M.new = function(args)
    local instance = {}

    local __kind = args.kind
    local __resources = args.resources
    local __when_select = args.when_select
        or function(selection)
            print("Selected " .. selection.display)
        end
    local __is_current = args.is_current or function(_entry)
        return false
    end

    vim.validate({
        __kind = { __kind, "string" },
        __resources = { __resources, "table" },
        __when_select = { __when_select, "function" },
        __is_current = { __is_current, "function" },
    })

    ---@private
    ---@type string
    instance._kind = __kind
    ---@private
    ---@type table
    instance._resources = __resources
    ---@private
    ---@type function
    instance._when_select = __when_select
    ---@private
    ---@type function
    instance._is_current = __is_current

    ---@private
    ---@type table
    instance._preview_opts = {
        title = "detail",
        dyn_title = function(_, entry)
            return "detail - " .. entry.display
        end,
        define_preview = function(preview, entry, _status)
            local preview_data = instance._resources.get(entry.value)

            vim.api.nvim_buf_set_option(preview.state.bufnr, "ft", "lua")
            vim.api.nvim_buf_set_lines(
                preview.state.bufnr,
                0,
                -1,
                false,
                vim.fn.split(tostring(vim.inspect(preview_data)), "\n")
            )
        end,
    }

    ---@private
    ---@type table
    instance._results = instance._resources.list_iter():tolist()

    ---@private
    ---@type integer
    instance._default_selection_index = 0
    for i, elem in ipairs(instance._results) do
        if instance._is_current(elem) then
            instance._default_selection_index = i
        end
    end

    ---@public
    ---@type Picker
    instance.picker = pickers.new({}, {
        prompt_title = instance._kind,
        finder = finders.new_table({
            results = instance._results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.metadata.name,
                    ordinal = entry.metadata.name,
                }
            end,
        }),
        default_selection_index = instance._default_selection_index,
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            map("n", "e", function()
                local selection = action_state.get_selected_entry()
                local data = instance._resources.get(selection.value)

                local buffer = detail.create(instance._kind, data, function(ev)
                    if instance._resources.patch ~= nil then
                        local content_raw = utils.join_to_string(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
                        local content = load("return " .. content_raw)()
                        local diff = utils.calculate_diffs(data, content)

                        instance._resources.patch({
                            target = selection.value,
                            body = vim.json.encode(diff),
                        })
                    end
                end)
                actions.close(prompt_bufnr)
                vim.api.nvim_set_current_buf(buffer)
            end)

            actions.select_default:replace(function()
                actions.close(prompt_bufnr)

                local selection = action_state.get_selected_entry()
                instance._when_select(selection)
            end)

            return true
        end,
        previewer = previewers.new_buffer_previewer(instance._preview_opts),
    })

    return instance
end

return M
