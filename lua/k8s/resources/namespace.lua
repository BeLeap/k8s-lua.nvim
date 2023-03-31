local curl = require("plenary.curl")
local iterators = require("plenary.iterators")

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

        local items_iter = iterators.iter(data.items)
        local names_iter = items_iter:map(function(item)
            return item.metadata.name
        end)

        vim.ui.select(names_iter:tolist(), {}, function(_choice) end)
    end
end

return M
