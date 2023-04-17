local kube_config = require("k8s.kube_config")

---@module 'context'
local M = {}

-- get current context
---@return string|nil
M.get_current = function()
    local parser, tree = kube_config.load_config()

    local ts_query = [[
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key:   ((flow_node) @currentContext
                (#eq? @currentContext "current-context"))
        value: (flow_node) @value
      )
    )
  )
)
    ]]

    local query = vim.treesitter.query.parse("yaml", ts_query)

    for id, node, _ in query:iter_captures(tree[1]:root(), parser:source(), 0, -1) do
        local name = query.captures[id]

        if name == "value" then
            return vim.treesitter.get_node_text(node, parser:source())
        end
    end

    return nil
end

-- get list of contexts
M.list = function()
    local parser, tree = kube_config.load_config()

    local ts_query = [[
(document
  (block_node
    (block_mapping
      (block_mapping_pair
        key:   ((flow_node) @contexts
                (#eq? @contexts "contexts"))
        value: (block_node
                 (block_sequence
                   (block_sequence_item
                     (block_node
                       (block_mapping
                         (block_mapping_pair
                           key:   ((flow_node) @name
                                   (#eq? @name "name"))
                           value: (flow_node) @value
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
    for id, node, _ in query:iter_captures(tree[1]:root(), parser:source(), 0, -1) do
        local name = query.captures[id]

        if name == "value" then
            vim.list_extend(contexts, { vim.treesitter.get_node_text(node, parser:source()) })
        end
    end

    return contexts
end

return M
