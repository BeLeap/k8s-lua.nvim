local curl = require("plenary.curl")
local proxy = require("k8s.api.proxy")

local M = {}

-- @return table|nil
M.get = function(path)
    vim.validate({
        path = { path, "string" },
    })
    proxy.update()

    vim.wait(1000, function()
        return proxy.port ~= nil
    end, 100)

    local url = "localhost:" .. tostring(proxy.port) .. path
    local res = curl.get(url)

    local data = nil
    if res ~= nil then
        data = vim.json.decode(res.body)
    end

    return data
end

return M
