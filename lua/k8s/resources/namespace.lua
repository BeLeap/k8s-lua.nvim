local iterators = require("plenary.iterators")

local client = require("k8s.api.client")

local M = {}

M.get = function(namespace)
    vim.validate({
        namespace = { namespace, "string" },
    })

    return client.get("/api/v1/namespaces/" .. tostring(namespace))
end

-- @return array|nil
M.list = function()
    local data = client.get("/api/v1/namespaces")

    if data ~= nil then
        local items_iter = iterators.iter(data.items)
        local names_iter = items_iter:map(function(item)
            return item.metadata.name
        end)
        return names_iter:tolist()
    end
end

return M
