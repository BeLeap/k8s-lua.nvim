local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local resources_namespace = require("k8s.resources.namespace")
local detail_buffer = require("k8s.ui.detail_buffer")
local preview_buffer = require("k8s.ui.preview_buffer")

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
                    results = names_iter
                        :map(function(elem)
                            return { name = elem }
                        end)
                        :tolist(),
                    entry_maker = function(entry)
                        local value = vim.tbl_deep_extend("keep", entry, {
                            preview_data_fetcher = {
                                call = resources_namespace.get,
                                args = {
                                    namespace = entry.name,
                                },
                            },
                        })
                        return {
                            value = value,
                            display = entry.name,
                            ordinal = entry.name,
                        }
                    end,
                }),
                default_selection_index = selected_idx,
                sorter = conf.generic_sorter(),
                attach_mappings = function(prompt_bufnr, map)
                    map("n", "e", function()
                        local selection = action_state.get_selected_entry()
                        local data = resources_namespace.get({
                            namespace = selection.value.name,
                        })

                        local buffer = detail_buffer.create("namespaces", selection.value.name, data, {})
                        actions.close(prompt_bufnr)
                        vim.api.nvim_set_current_buf(buffer)
                    end)

                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        resources_namespace.target = selection.value.name
                    end)
                    return true
                end,
                previewer = previewers.new_buffer_previewer(preview_buffer.previewer_opt_factory()),
            })
            :find()
    end
end

return M
