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
    local kind = args.kind
    local resources = args.resources
    local when_select = args.when_select or function(selection)
        print("Selected " .. selection.display)
    end
    local is_current = args.is_current or function(_entry)
        return false
    end

    vim.validate({
        kind = { kind, "string" },
        resources = { resources, "table" },
        when_select = { when_select, "function" },
        is_current = { is_current, "function" },
    })

    local iter = resources.list_iter()
    local results = iter:tolist()

    local default_selection_index = 0
    for i, elem in ipairs(results) do
        if is_current(elem) then
            default_selection_index = i
        end
    end

    local picker = pickers.new({}, {
        prompt_title = kind,
        finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.metadata.name,
                    ordinal = entry.metadata.name,
                }
            end,
        }),
        default_selection_index = default_selection_index,
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            map("n", "e", function()
                local selection = action_state.get_selected_entry()
                local data = resources.get(selection.value)

                local buffer = detail.create(kind, selection.value.metadata.name, data, function(ev)
                    if resources.patch ~= nil then
                        local content_raw = utils.join_to_string(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
                        local content = load("return " .. content_raw)()
                        local diff = utils.calculate_diffs(data, content)

                        resources.patch({
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
                when_select(selection)
            end)

            return true
        end,
        previewer = previewers.new_buffer_previewer({
            title = "Describe",
            dyn_title = function(_, entry)
                return "Describe - " .. entry.display
            end,
            define_preview = function(self, entry, _status)
                local preview_data = resources.get(entry.value)

                vim.api.nvim_buf_set_option(self.state.bufnr, "ft", "lua")
                vim.api.nvim_buf_set_lines(
                    self.state.bufnr,
                    0,
                    -1,
                    false,
                    vim.fn.split(tostring(vim.inspect(preview_data)), "\n")
                )
            end,
        }),
    })

    return picker
end

return M