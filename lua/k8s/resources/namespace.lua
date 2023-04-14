local iterators = require("plenary.iterators")

local client = require("k8s.api.client")

-- @field target string|nil
local M = {
    target = nil,
}

M.get = function(target)
    local name = target.metadata.name

    vim.validate({
        name = { name, "string" },
    })

    return client.get("/api/v1/namespaces/" .. name)
end

-- @return iterator|nil
M.list_iter = function()
    local data = client.get("/api/v1/namespaces")

    if data ~= nil then
        return iterators.iter(data.items)
    end
end

return M
