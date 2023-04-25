local client = require("k8s.api.client")

---@class KubernetesResources: Resources
---@field public api_version string
---@field public is_namespaced boolean
---@field protected api_prefix string
local KubernetesResources = {}

---@param kind string
---@param api_version string
---@param is_namespaced boolean
---@param namespace string|nil
---@return KubernetesResources
function KubernetesResources:new(kind, api_version, is_namespaced, namespace)
    vim.validate({
        kind = { kind, "string" },
        api_version = { api_version, "string" },
        is_namespaced = { is_namespaced, "boolean" },
        namespace = { namespace, { "string", "nil" } },
    })

    local o = {}
    o = vim.deepcopy(self)

    o.kind = kind
    o.api_version = api_version
    o.is_namespaced = is_namespaced
    o.namespace = namespace

    local api_prefix = "/" .. o.api_version
    if o.is_namespaced and o.namespace ~= nil then
        api_prefix = api_prefix .. "/namespaces/" .. o.namespace
    end
    api_prefix = api_prefix .. "/" .. o.kind
    o.api_prefix = api_prefix

    return o
end

---@param metadata KubernetesObjectMeta
---@param body string
function KubernetesResources:patch(metadata, body)
    vim.validate({
        target = { metadata, "table" },
        body = { body, "string" },
    })

    local name = metadata.name
    vim.validate({
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
    return client.get(self.api_prefix .. "/" .. name)
end

return KubernetesResources
