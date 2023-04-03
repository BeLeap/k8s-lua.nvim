local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local kube_config = require("k8s.kube_config")

local M = {}

-- get current context
-- @return string|nil
M._get_current = function()
    local parser, tree = kube_config._load_config()

    local ts_query = [[
    (document
      (block_node
        (block_mapping
          (block_mapping_pair
            key:   ((flow_node) @constant
                    (#eq? @constant "current-context"))
            value: (flow_node
                     (plain_scalar)
                     @capture
                   )
          )
        )
      )
    )
    ]]

    local query = vim.treesitter.query.parse("yaml", ts_query)

    for _, node, _ in query:iter_captures(tree[1]:root(), parser:source(), 0, 1000) do
        if node:type() == "plain_scalar" then
            return vim.treesitter.get_node_text(node, parser:source())
        end
    end

    return nil
end

-- get list of contexts
M._get_list = function()
    local parser, tree = kube_config._load_config()

    local ts_query = [[
    (document
      (block_node
        (block_mapping
          (block_mapping_pair
            key:   ((flow_node) @constant
                    (#eq? @constant "contexts"))
            value: (block_node
                     (block_sequence
                       (block_sequence_item
                         (block_node
                           (block_mapping
                             (block_mapping_pair
                               key:   ((flow_node) @field
                                       (#eq? @field "name"))
                               value: (flow_node
                                        (plain_scalar) @capture
                                      )
                             )
                           )
                         )
                       )
                     )
                   )
          )
        )
      )
    )
    ]]

    local query = vim.treesitter.query.parse("yaml", ts_query)

    local contexts = {}
    for _, node, _ in query:iter_captures(tree[1]:root(), parser:source(), 0, 1000) do
        if node:type() == "plain_scalar" then
            vim.list_extend(contexts, { vim.treesitter.get_node_text(node, parser:source()) })
        end
    end

    return contexts
end

-- select context with telescope picker
M.select_context = function()
    local contexts = M._get_list()

    pickers
        .new({}, {
            prompt_title = "Contexts",
            finder = finders.new_table({
                results = contexts,
                entry_maker = function(context)
                    local display = "  " .. context
                    if context == M.target_context then
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
                    M.target_context = selection.value
                end)
                return true
            end,
        })
        :find()
end

M.setup = function(_config)
    M.target_context = M._get_current()
end

return M
