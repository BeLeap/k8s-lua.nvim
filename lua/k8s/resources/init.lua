local client = require("k8s.api.client")

---@class KubernetesResources: Resources
---@field public is_namespaced boolean
---@field public api_prefix string
local KubernetesResources = {}

---@param kind string
---@param api string
---@param api_group string
---@param is_namespaced boolean
---@param namespace string|nil
---@return KubernetesResources
function KubernetesResources:new(kind, api, api_group, is_namespaced, namespace)
    local o = {}
    o = vim.deepcopy(self)

    o.kind = kind
    o.api_group = api_group
    o.is_namespaced = is_namespaced
    o.namespace = namespace

    local fqdn = api_group
    if o.is_namespaced and o.namespace ~= nil then
        fqdn = fqdn .. "/namespaces/" .. o.namespace
    end
    fqdn = fqdn .. "/" .. o.kind
    o.fqdn = fqdn

    o.api_prefix = "/" .. api .. "/" .. fqdn

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
