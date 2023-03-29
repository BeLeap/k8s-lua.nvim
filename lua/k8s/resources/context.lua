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

-- select context with vim.ui.select
M.select_context = function()
    local contexts = M._get_list()
    vim.ui.select(contexts, {
        prompt = "Select target contexts:",
        format_item = function(context)
            if context == M.target_context then
                return "* " .. context
            else
                return "  " .. context
            end
        end,
    }, function(choice)
        if choice ~= nil then
            M.target_context = choice
            print(M.target_context)
        end
    end)
end

M.setup = function(_config)
    M.target_context = M._get_current()
end

return M
