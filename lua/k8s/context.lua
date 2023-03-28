local ts_utils = require("nvim-treesitter.ts_utils")

local utils = require("k8s.utils")
local constants = require("k8s.constants")

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
                           key: ((flow_node) @field
                                 (#eq? @field "name"))
                           value: (flow_node) @capture
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

M.read_config = function()
	local content = utils.readfile(constants.kubeconfig)

	local parser = vim.treesitter.get_string_parser(content, "yaml")
	local tree = parser:parse()

	-- for key, value in pairs(getmetatable(tree[1])) do
	-- 	print(key, value)
	-- end

	local query = vim.treesitter.query.parse("yaml", context_names_query)
	for id, node, metadata in query:iter_captures(tree[1]:root(), parser:source(), 0, 1000) do
		print(vim.treesitter.get_node_text(node, parser:source()))
	end
end

return M
