local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

local utils = require("k8s.utils")
local detail_buffer = require("k8s.ui.detail_buffer")

local M = {}

M.new = function(args)
    local kind = args.kind
    local resources = args.resources
    local when_select = args.when_select or function(selection)
        print("Selected " .. selection.display)
    end

    vim.validate({
        kind = { kind, "string" },
        resources = { resources, "table" },
        when_select = { when_select, "function" },
    })

    local list = resources.list_iter()

    local picker = pickers.new({}, {
        prompt_title = kind,
        finder = finders.new_table({
            results = list:tolist(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.metadata.name,
                    ordinal = entry.metadata.name,
                }
            end,
        }),
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            map("n", "e", function()
                local selection = action_state.get_selected_entry()
                local data = resources.get(selection.value)

                local buffer = detail_buffer.create(kind, selection.value.metadata.name, data, function(ev)
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
