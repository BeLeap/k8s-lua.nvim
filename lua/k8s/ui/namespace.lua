local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local resources_namespace = require("k8s.resources.namespace")
local detail_buffer = require("k8s.ui.detail_buffer")

local M = {}

M.select = function()
    local iter = resources_namespace.list_iter()

    if iter ~= nil then
        local names_iter = iter:map(function(item)
            return item.metadata.name
        end)
        local names = names_iter:tolist()

        local selected_idx
        for i, v in ipairs(names) do
            if v == resources_namespace.target then
                selected_idx = i
            end
        end

        pickers
            .new({}, {
                prompt_title = "Namespaces",
                finder = finders.new_table({
                    results = names_iter:tolist(),
                    entry_maker = function(name)
                        return {
                            value = name,
                            display = name,
                            ordinal = name,
                        }
                    end,
                }),
                default_selection_index = selected_idx,
                sorter = conf.generic_sorter(),
                attach_mappings = function(prompt_bufnr, map)
                    map("n", "e", function()
                        local selection = action_state.get_selected_entry()
                        local data = resources_namespace.get(selection.value)

                        local buffer = detail_buffer.create("namespaces", selection.value, data)
                        actions.close(prompt_bufnr)
                        vim.api.nvim_set_current_buf(buffer)
                    end)

                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        resources_namespace.target = selection.value
                    end)
                    return true
                end,
                previewer = previewers.new_buffer_previewer({
                    title = "Describe",
                    dyn_title = function(_, entry)
                        return "Describe - " .. entry.display
                    end,
                    define_preview = function(self, entry, _status)
                        local preview_data = resources_namespace.get(entry.value)
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
            :find()
    end
end

return M
