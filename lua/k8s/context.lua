local utils = require("k8s.utils")
local config = require("k8s").config

local M = {}

local context_names_query = [[
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

M.get = function()
	local content = utils.readfile(config.kubeconfig_location)

	vim.treesitter.language.add("yaml")
	local parser = vim.treesitter.get_string_parser(content, "yaml")
	local tree = parser:parse()

	local query = vim.treesitter.query.parse("yaml", context_names_query)
	local contexts = {}
	for _, node, _ in query:iter_captures(tree[1]:root(), parser:source(), 0, 1000) do
		if node:type() == "plain_scalar" then
			vim.list_extend(contexts, { vim.treesitter.get_node_text(node, parser:source()) })
		end
	end

	return contexts
end

return M
