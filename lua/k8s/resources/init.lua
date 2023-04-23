local client = require("k8s.api.client")

---@class KubernetesResources: Resources
---@field public api_version string
---@field public is_namespaced boolean
---@field private api_prefix string
local KubernetesResources = {}

---@param kind string
---@param api_version string
---@param is_namespaced boolean
---@param namespace string|nil
function KubernetesResources:new(kind, api_version, is_namespaced, namespace)
    vim.validate({
        kind = { kind, "string" },
        api_version = { api_version, "string" },
        is_namespaced = { is_namespaced, "boolean" },
        namespace = { namespace, { "string", "nil" } },
    })

    self.kind = kind
    self.api_version = api_version
    self.is_namespaced = is_namespaced
    self.namespace = namespace

    local api_prefix = "/" .. self.api_version
    if self.is_namespaced and self.namespace ~= nil then
        api_prefix = api_prefix .. "/namespaces/" .. self.namespace
    end
    api_prefix = api_prefix .. "/" .. self.kind
    self.api_prefix = api_prefix

    return self
end

---@param metadata KubernetesObjectMeta
---@param body string
function KubernetesResources:patch(metadata, body)
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

    return client.patch(self.api_prefix .. "/" .. name, body)
end

---@return KubernetesObject[]|nil
function KubernetesResources:list()
    local data
    data = client.get(self.api_prefix)

    if data ~= nil then
        return data.items
    end
end

---@param name string
---@return KubernetesObject|nil
function KubernetesResources:get(name)
    print(self.api_prefix .. "/" .. name)
    return client.get(self.api_prefix .. "/" .. name)
end

return KubernetesResources
