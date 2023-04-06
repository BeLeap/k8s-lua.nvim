local kube_config = require("k8s.kube_config")

-- @field target string|nil
local M = {
    target = nil,
}

-- get current context
-- @return string|nil
M.get_current = function()
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
M.list = function()
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

M.setup = function(_config)
    M.target = M.get_current()
end

return M
