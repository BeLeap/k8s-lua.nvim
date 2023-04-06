local iterators = require("plenary.iterators")

local client = require("k8s.api.client")

local resources_namespace = require("k8s.resources.namespace")

local M = {}

M.get = function(namespace, pod)
    vim.validate({
        pod = { pod, "string" },
    })

    return client.get("/api/v1/namespaces/" .. namespace .. "/pods/" .. tostring(pod))
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
