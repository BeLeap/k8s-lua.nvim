local client = require("k8s.api.client")

---@class KubernetesResources: Resources
---@field public api string
---@field public api_group string
---@field public is_namespaced boolean
---@field public namespace string|nil
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
  o.api = api
  o.api_group = api_group
  o.is_namespaced = is_namespaced
  o.namespace = namespace

  return o
end

---@param namespace string|nil
function KubernetesResources:build_fqdn(namespace)
  local fqdn = self.api_group

  if self.is_namespaced then
    if self.namespace ~= nil then
      fqdn = fqdn .. "/namespaces/" .. self.namespace
    elseif namespace ~= nil then
      fqdn = fqdn .. "/namespaces/" .. namespace
    end
  end

  fqdn = fqdn .. "/" .. self.kind

  return fqdn
end

---@param fqdn string
function KubernetesResources:build_url(fqdn)
  return "/" .. self.api .. "/" .. fqdn
end

---@param metadata KubernetesObjectMeta
---@param body string
function KubernetesResources:patch(metadata, body)
  return client.patch(self:build_url(self:build_fqdn(metadata.namespace)) .. "/" .. metadata.name, body)
end

---@return KubernetesObject[]|nil
function KubernetesResources:list()
  local data
  data = client.get(self:build_url(self:build_fqdn()))

  if data ~= nil then
    return data.items
  end
end

---@param name string
---@return KubernetesObject|nil
function KubernetesResources:get(name)
  return client.get(self:build_url(self:build_fqdn()) .. "/" .. name)
end

return KubernetesResources
