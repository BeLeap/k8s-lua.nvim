local curl = require("plenary.curl")

local proxy = require("k8s.api.proxy")

local M = {}

M.list = function()
    if proxy.started == false then
        proxy.start()
    end

    vim.wait(1000, function()
        return proxy.port ~= nil
    end, 100)

    local url = "localhost:" .. tostring(proxy.port) .. "/api/v1/namespaces"
    local res = curl.get(url)

    if res ~= nil then
        local data = vim.fn.json_decode(res.body)
        print(vim.inspect(data))
    end
end

return M
