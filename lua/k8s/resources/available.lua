local client = require("k8s.api.client")
local resources_util = require("k8s.resources.util")

local M = {}

M.get_apis = function()
  local names = { "config", "core" }
  local result = client.get("/apis")

  if result ~= nil then
    local groups = {}
    for k, v in pairs(result) do
      if k == "groups" then
        groups = v
      end
    end

    for _, v in ipairs(groups) do
      table.insert(names, v.preferredVersion.groupVersion)
    end
  else
    vim.notify("List apis request failed", vim.log.levels.ERROR)
  end

  return names
end

---@param api_group string
---@return string[]
M.get_resources = function(api_group)
  if api_group == "config" then
    return { "contexts" }
  end

  local names = {}
  local result = client.get(resources_util.path_mapper(api_group))

  if result ~= nil then
    local resources = {}
    for k, v in pairs(result) do
      if k == "resources" then
        resources = v
      end
    end

    for _, v in ipairs(resources) do
      table.insert(names, v.name)
    end
  else
    vim.notify("List " .. api_group .. " resources request failed", vim.log.levels.ERROR)
  end

  return names
end

---@param api_group string
---@param kind string
---@return boolean
M.is_namespaced = function(api_group, kind)
  local result = client.get(resources_util.path_mapper(api_group))
  if result == nil then
    vim.notify("List " .. api_group .. " resources request failed", vim.log.levels.ERROR)

    return false
  end

  local resources = {}
  for k, v in pairs(result) do
    if k == "resources" then
      resources = v
    end
  end

  local namespaced = false
  for _, v in ipairs(resources) do
    if v.name == kind then
      namespaced = v.namespaced
    end
  end

  return namespaced
end
return M
