local available = require("k8s.resources.available")

local M = {}

---@param source_list string[]
---@param arglead string
---@return string[]
local matcher = function(source_list, arglead)
  local match = {}
  if arglead ~= nil then
    for _, element in ipairs(source_list) do
      if vim.startswith(element, arglead) then
        table.insert(match, element)
      end
    end
  else
    match = source_list
  end

  return match
end

---@param arglead string
---@return string[]
M.apis_completer = function(arglead)
  local apis = available.get_apis()

  return matcher(apis, arglead)
end

M.resources_completer = function(api, arglead)
  return matcher(available.get_resources(api), arglead)
end

return M
