local config = require("k8s.config")
local utils = require("k8s.utils")

---@class KubeConfig
---@field config { kube_config: { location: string } }
local M = {
  config = {
    kube_config = {},
  },
}

-- load kubeconfig as LangaugeTree and TSTree
---@return LanguageTree
---@return TSTree
M.load_config = function()
  local content = utils.readfile(vim.fs.normalize(config.kube_config.location or "~/.kube/config"))

  vim.treesitter.language.add("yaml")
  local parser = vim.treesitter.get_string_parser(content, "yaml")
  local tree = parser:parse()

  return parser, tree
end

return M
