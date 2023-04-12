local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local utils = require("k8s.utils")

local detail_buffer = require("k8s.ui.detail_buffer")
local preview_buffer = require("k8s.ui.preview_buffer")

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
                        local value = vim.tbl_deep_extend("keep", entry, {
                            preview_data_fetcher = {
                                call = resources_pod.get,
                                args = {
                                    namespace = entry.namespace,
                                    pod = entry.name,
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
                sorter = conf.generic_sorter(),
                attach_mappings = function(prompt_bufnr, map)
                    map("n", "e", function()
                        local selection = action_state.get_selected_entry()
                        local data = resources_pod.get({
                            namespace = selection.value.namespace,
                            pod = selection.value.name,
                        })

                        local buffer = detail_buffer.create("pods", selection.value.name, data, function(ev)
                            local content_lua_string =
                                utils.join_to_string(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
                            local content = vim.json.encode(load("return " .. content_lua_string)())

                            resources_pod.patch({
                                namespace = selection.value.namespace,
                                pod = selection.value.name,
                                body = content,
                            })
                        end)

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
                previewer = previewers.new_buffer_previewer(preview_buffer.previewer_opt_factory()),
            })
            :find()
    end
end

return M
