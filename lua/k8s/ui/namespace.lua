local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local resources_namespace = require("k8s.resources.namespace")

local M = {}

M.select = function()
    local names = resources_namespace.list_iter()

    if names ~= nil then
        pickers
            .new({}, {
                prompt_title = "Namespaces",
                finder = finders.new_table({
                    results = names
                        :map(function(item)
                            return item.metadata.name
                        end)
                        :tolist(),
                    entry_maker = function(name)
                        local display = "  " .. name
                        if name == resources_namespace.target_namespace then
                            display = "* " .. name
                        end

                        return {
                            value = name,
                            display = display,
                            ordinal = name,
                        }
                    end,
                }),
                sorter = conf.generic_sorter(),
                attach_mappings = function(prompt_bufnr, _map)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        resources_namespace.target_namespace = selection.value
                    end)
                    return true
                end,
                previewer = previewers.new_buffer_previewer({
                    title = "Describe",
                    dyn_title = function(_, entry)
                        return "Describe - " .. entry.value
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
