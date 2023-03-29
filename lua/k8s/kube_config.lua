local utils = require("k8s.utils")

-- @module context
-- @alias M
-- @field config table config
-- @field target_context string|nil target context
local M = {
    config = {
        kube_config = {},
    },
}

-- load kubeconfig as LangaugeTree and TSTree
-- @return LanguageTree, TSTree treesitter objects of kubeconfig
M._load_config = function()
    local content = utils.readfile(vim.fs.normalize(M.config.kube_config.location or "~/.kube/config"))

    vim.treesitter.language.add("yaml")
    local parser = vim.treesitter.get_string_parser(content, "yaml")
    local tree = parser:parse()

    return parser, tree
end

-- initial setup
M.setup = function(config)
    M.config.kube_config = config.kube_config
end

return M
