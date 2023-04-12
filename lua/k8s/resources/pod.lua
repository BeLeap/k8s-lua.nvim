local iterators = require("plenary.iterators")

local client = require("k8s.api.client")

local resources_namespace = require("k8s.resources.namespace")

local M = {}

M.get = function(args)
    local pod = args.pod
    local namespace = args.namespace

    vim.validate({
        pod = { pod, "string" },
        namespace = { namespace, "string" },
    })

    return client.get("/api/v1/namespaces/" .. namespace .. "/pods/" .. pod)
end

M.patch = function(args)
    local pod = args.pod
    local namespace = args.namespace
    local body = args.body

    vim.validate({
        pod = { pod, "string" },
        namespace = { namespace, "string" },
        body = { body, "string" },
    })

    return client.patch("/api/v1/namespaces/" .. namespace .. "/pods/" .. pod, body)
end

-- @return iterator|nil
M.list_iter = function()
    local data
    if resources_namespace.target ~= nil then
        data = client.get("/api/v1/namespaces/" .. resources_namespace.target .. "/pods")
    else
        data = client.get("/api/v1/pods")
    end

    if data ~= nil then
        return iterators.iter(data.items)
    end
end

return M
