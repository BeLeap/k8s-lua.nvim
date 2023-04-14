local iterators = require("plenary.iterators")

local client = require("k8s.api.client")

local resources_namespace = require("k8s.resources.namespace")

local M = {}

M.get = function(target)
    local metadata = target.metadata
    vim.validate({
        metadata = { metadata, "table" },
    })

    local name = metadata.name
    local namespace = metadata.namespace
    vim.validate({
        name = { name, "string" },
        namespace = { namespace, "string" },
    })

    return client.get("/api/v1/namespaces/" .. namespace .. "/pods/" .. name)
end

M.patch = function(args)
    local target = args.target
    local body = args.body

    vim.validate({
        target = { target, "table" },
        body = { body, "string" },
    })

    local namespace = target.metadata.namespace
    local name = target.metadata.name

    vim.validate({
        namespace = { namespace, "string" },
        name = { name, "string" },
    })

    return client.patch("/api/v1/namespaces/" .. namespace .. "/pods/" .. name, body)
end

-- @return iterator|nil
M.list_iter = function()
    local data
    if resources_namespace.current_name ~= nil then
        data = client.get("/api/v1/namespaces/" .. resources_namespace.current_name .. "/pods")
    else
        data = client.get("/api/v1/pods")
    end

    if data ~= nil then
        return iterators.iter(data.items)
    end
end

return M
