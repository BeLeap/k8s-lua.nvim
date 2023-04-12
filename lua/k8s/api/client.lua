local curl = require("plenary.curl")
local proxy = require("k8s.api.proxy")

local M = {}

-- @return table|nil
M.get = function(path)
    vim.validate({
        path = { path, "string" },
    })
    proxy.check()

    local url = "localhost:" .. tostring(proxy.port) .. path
    local res = curl.get(url)

    local data = nil
    if res ~= nil then
        data = vim.json.decode(res.body)
    end

    return data
end

M.patch = function(path, body)
    vim.validate({
        path = { path, "string" },
        body = { body, "string" },
    })
    proxy.check()

    local url = "localhost:" .. tostring(proxy.port) .. path
    local res = curl.patch(url, {
        headers = {
            ["Content-Type"] = "application/merge-patch+json",
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
