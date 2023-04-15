local iterators = require("plenary.iterators")

local client = require("k8s.api.client")

local resources_namespace = require("k8s.resources.namespace")

---@class NamespacedResource
---@field kind string
local NamespacedResource = {}

function NamespacedResource:new(kind)
    vim.validate({
        kind = { kind, "string" },
    })

    self.kind = kind

    return self
end

---@param metadata KubernetesObjectMeta
---@return KubernetesObject
function NamespacedResource:get(metadata)
    vim.validate({
        metadata = { metadata, "table" },
    })

    local name = metadata.name
    local namespace = metadata.namespace
    vim.validate({
        name = { name, "string" },
        namespace = { namespace, "string" },
    })

    return client.get("/api/v1/namespaces/" .. namespace .. "/" .. self.kind .. "/" .. name)
end

---@param metadata KubernetesObjectMeta
---@param body string
function NamespacedResource:patch(metadata, body)
    vim.validate({
        target = { metadata, "table" },
        body = { body, "string" },
    })

    local name = metadata.name
    local namespace = metadata.namespace
    vim.validate({
        namespace = { namespace, "string" },
        name = { name, "string" },
    })

    return client.patch("/api/v1/namespaces/" .. namespace .. "/" .. self.kind .. "/" .. name, body)
end

---@return Iterator|nil
function NamespacedResource:list_iter()
    local data
    if resources_namespace.current_name ~= nil then
        data = client.get("/api/v1/namespaces/" .. resources_namespace.current_name .. "/" .. self.kind)
    else
        data = client.get("/api/v1/" .. self.kind)
    end

    if data ~= nil then
        return iterators.iter(data.items)
    end
end

return NamespacedResource
