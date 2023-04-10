local iterators = require("plenary.iterators")

local client = require("k8s.api.client")

-- @field target string|nil
local M = {
    target = nil,
}

M.get = function(args)
    local namespace = args.namespace

    vim.validate({
        namespace = { namespace, "string" },
    })

    return client.get("/api/v1/namespaces/" .. namespace)
end

-- @return iterator|nil
M.list_iter = function()
    local data = client.get("/api/v1/namespaces")

    if data ~= nil then
        return iterators.iter(data.items)
    end
end

return M
