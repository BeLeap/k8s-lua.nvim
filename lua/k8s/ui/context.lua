local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local resources_context = require("k8s.resources.context")

local M = {}

-- select context with telescope picker
M.select_context = function()
    local contexts = resources_context.get_list()

    pickers
        .new({}, {
            prompt_title = "Contexts",
            finder = finders.new_table({
                results = contexts,
                entry_maker = function(context)
                    local display = "  " .. context
                    if context == resources_context.target_context then
                        display = "* " .. context
                    end

                    return {
                        value = context,
                        display = display,
                        ordinal = context,
                    }
                end,
            }),
            sorter = conf.generic_sorter(),
            attach_mappings = function(prompt_bufnr, _map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    contexts.target_context = selection.value
                end)
                return true
            end,
        })
        :find()
end

return M
