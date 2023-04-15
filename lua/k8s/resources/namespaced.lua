local iterators = require("plenary.iterators")

local client = require("k8s.api.client")

local resources_namespace = require("k8s.resources.namespace")

local M = {}

---@param kind string
---@param metadata KubernetesObjectMeta
M.get = function(kind, metadata)
    vim.validate({
        kind = { kind, "string" },
        metadata = { metadata, "table" },
    })

    local name = metadata.name
    local namespace = metadata.namespace
    vim.validate({
        name = { name, "string" },
        namespace = { namespace, "string" },
    })

    return client.get("/api/v1/namespaces/" .. namespace .. "/" .. kind .. "/" .. name)
end

---@param kind string
---@param metadata KubernetesObjectMeta
---@param body string
M.patch = function(kind, metadata, body)
    vim.validate({
        kind = { kind, "string" },
        target = { metadata, "table" },
        body = { body, "string" },
    })

    local namespace = metadata.namespace
    local name = metadata.name

    vim.validate({
        namespace = { namespace, "string" },
        name = { name, "string" },
    })

    return client.patch("/api/v1/namespaces/" .. namespace .. "/" .. kind .. "/" .. name, body)
end

---@param kind string
---@return Iterator|nil
M.list_iter = function(kind)
    vim.validate({
        kind = { kind, "string" },
    })

    local data
    if resources_namespace.current_name ~= nil then
        data = client.get("/api/v1/namespaces/" .. resources_namespace.current_name .. "/" .. kind)
    else
        data = client.get("/api/v1/" .. kind)
    end

    if data ~= nil then
        return iterators.iter(data.items)
    end
end

return M
