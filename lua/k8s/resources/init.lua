local iterators = require("plenary.iterators")

local client = require("k8s.api.client")

---@class Resource
---@field public kind string
---@field public api_version string
---@field public is_namespaced boolean
---@field private api_prefix string
local Resource = {}

---@param kind string
---@param api_version string
---@param is_namespaced boolean
---@param namespace string|nil
function Resource:new(kind, api_version, is_namespaced, namespace)
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
    if self.is_namespaced then
        api_prefix = api_prefix .. "/namespaces/" .. self.namespace
    end
    api_prefix = api_prefix .. "/" .. self.kind
    self.api_prefix = api_prefix

    return self
end

---@param metadata KubernetesObjectMeta
---@param body string
function Resource:patch(metadata, body)
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

---@return Iterator|nil
function Resource:list_iter()
    local data
    data = client.get(self.api_prefix)

    -- else
    --     data = client.get("/api/" .. self.api_version .. "/" .. self.kind)
    -- end

    if data ~= nil then
        return iterators.iter(data.items)
    end
end

return Resource
