local curl = require("plenary.curl")
local api_proxy = require("k8s.api.proxy")
local global_contexts = require("k8s.global_contexts")

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

---@return string|nil
M.get_raw_body = function(path)
    vim.validate({
        path = { path, "string" },
    })
    M.update_proxy()

    local url = "localhost:" .. tostring(M.proxy.port) .. path
    print(url)
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

return M
