local client = require("k8s.api.client")

local M = {}

M.get_apis = function()
  local result = client.get("/apis")

  if result == nil then
    vim.notify("List apis request failed", vim.log.levels.ERROR)

    return {}
  end

  local groups = {}
  for k, v in pairs(result) do
    if k == "groups" then
      groups = v
    end
  end

  local names = { "core" }
  for _, v in ipairs(groups) do
    table.insert(names, v.preferredVersion.groupVersion)
  end

  return names
end

---@param api string
---@return string[]
M.get_resources = function(api)
  local path = ""

  if api == "core" then
    path = "/api/v1"
  else
    path = "/apis/" .. api
  end

  local result = client.get(path)

  if result == nil then
    vim.notify("List " .. api .. " resources request failed", vim.log.levels.ERROR)

    return {}
  end

  local resources = {}
  for k, v in pairs(result) do
    if k == "resources" then
      resources = v
    end
  end

  local names = {}
  for _, v in ipairs(resources) do
    table.insert(names, v.name)
  end

  return names
end
return M
