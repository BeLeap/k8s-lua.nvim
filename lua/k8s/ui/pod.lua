local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local detail_buffer = require("k8s.ui.detail_buffer")

local resources_pod = require("k8s.resources.pod")

local M = {}

M.select = function()
    local names = resources_pod.list_iter()

    if names ~= nil then
        pickers
            .new({}, {
                prompt_title = "Pods",
                finder = finders.new_table({
                    results = names
                        :map(function(elem)
                            return {
                                namespace = elem.metadata.namespace,
                                name = elem.metadata.name,
                            }
                        end)
                        :tolist(),
                    entry_maker = function(entry)
                        return {
                            value = entry,
                            display = entry.name,
                            ordinal = entry.name,
                        }
                    end,
                }),
                sorter = conf.generic_sorter(),
                attach_mappings = function(prompt_bufnr, map)
                    map("n", "e", function()
                        local selection = action_state.get_selected_entry()
                        local data = resources_pod.get(selection.value.namespace, selection.value.name)

                        local buffer = detail_buffer.create("pods", selection.value.name, data)

                        actions.close(prompt_bufnr)
                        vim.api.nvim_set_current_buf(buffer)
                    end)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        print(vim.inspect(selection))
                    end)
                    return true
                end,
                previewer = previewers.new_buffer_previewer({
                    title = "Describe",
                    dyn_title = function(_, entry)
                        return "Describe - " .. entry.display
                    end,
                    define_preview = function(self, entry, _status)
                        local preview_data = resources_pod.get(entry.value.namespace, entry.value.name)
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
