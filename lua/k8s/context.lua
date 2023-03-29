local utils = require("k8s.utils")

-- @module context
-- @alias M
-- @field config config
-- @field target_context target context
local M = {
	config = {},
}

-- load kubeconfig as LangaugeTree and TSTree
-- @return LanguageTree, TSTree treesitter objects of kubeconfig
M._load_config = function()
	local content = utils.readfile(vim.fs.normalize(M.config.context.location))

	vim.treesitter.language.add("yaml")
	local parser = vim.treesitter.get_string_parser(content, "yaml")
	local tree = parser:parse()

	return parser, tree
end

-- get current context
M._get_current = function() end

-- get list of contexts
M._get_list = function()
	local parser, tree = M._load_config()

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

	local query = vim.treesitter.query.parse("yaml", context_names_query)

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
	}, function(choice)
		M.target_context = choice
		print(M.target_context)
	end)
end

-- initial setup
M.setup = function(config)
	M.config.context = config.context
end

return M
