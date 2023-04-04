local curl = require("plenary.curl")
local proxy = require("k8s.api.proxy")

local M = {}

-- @return table|nil
M.get = function(path)
    vim.validate({
        path = { path, "string" },
    })

    if proxy.started == false then
        proxy.start()
    end

    vim.wait(1000, function()
        return proxy.port ~= nil
    end, 100)

    local url = "localhost:" .. tostring(proxy.port) .. path
    local res = curl.get(url)

    if res ~= nil then
        return vim.json.decode(res.body)
    end
end

return M
