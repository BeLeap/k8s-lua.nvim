local curl = require("plenary.curl")
local api_proxy = require("k8s.api.proxy")
local global_contexts = require("k8s.global_contexts")

---@class CurlResponse
---@field status integer
---@field headers table<string, string>[]
---@field body string
---@field exit integer

---@class Client
---@field private proxy ApiProxy|nil
---@field private update_proxy fun(): nil
local M = {
  proxy = nil,
}

M.update_proxy = function()
  if M.proxy ~= nil then
    if M.proxy.started == true and M.proxy.context == global_contexts.selected_contexts then
      return
    else
      M.proxy:shutdown()
    end
  end

  local new_api_proxy = api_proxy:new(global_contexts.selected_contexts)
  new_api_proxy:start()

  vim.wait(10000, function()
    return new_api_proxy.port ~= nil
  end, 100)

  M.proxy = new_api_proxy
end

---@param path string
---@param query_param table<string,string>|nil
---@return string|nil
M.get_raw_body = function(path, query_param)
  vim.validate({
    path = { path, "string" },
  })
  M.update_proxy()

  local url = "localhost:" .. tostring(M.proxy.port) .. path

  if query_param ~= nil then
    url = url .. "?"

    local query_strings = {}
    for k, v in pairs(query_param) do
      table.insert(query_strings, k .. "=" .. v)
    end
    url = url .. table.concat(query_strings, "&")
  end

  local res = curl.get(url)

  if res ~= nil then
    return res.body
  end
end

---@return table|nil
M.get = function(path)
  local body = M.get_raw_body(path)

  local data = nil
  if body ~= nil then
    data = vim.json.decode(body)
  end

  return data
end

---@return table|nil
M.patch = function(path, body)
  vim.validate({
    path = { path, "string" },
    body = { body, "string" },
  })
  M.update_proxy()

  local url = "localhost:" .. tostring(api_proxy.port) .. path
  local res = curl.patch(url, {
    headers = {
      ["Content-Type"] = "application/json-patch+json",
    },
    body = body,
  })

  local data = nil
  if res ~= nil then
    data = vim.json.decode(res.body)
  end

  return data
end

---@param path string
---@return CurlResponse|nil
M.delete = function(path)
  M.update_proxy()

  local url = "localhost:" .. tostring(api_proxy.port) .. path
  return curl.delete(url)
end

return M
