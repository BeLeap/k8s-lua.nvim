local client = require("k8s.api.client")
local resources_util = require("k8s.resources.util")

---@class KubernetesResources: Resources
---@field public api_group string
---@field public is_namespaced boolean
---@field public namespace string|nil
local KubernetesResources = {}

---@param kind string
---@param api_group string
---| "core"
---@param is_namespaced boolean
---@param namespace string|nil
---@return KubernetesResources
function KubernetesResources:new(kind, api_group, is_namespaced, namespace)
  local o = {}
  o = vim.deepcopy(self)

  o.kind = kind
  o.api_group = api_group
  o.is_namespaced = is_namespaced
  o.namespace = namespace

  return o
end

---@param namespace string|nil
function KubernetesResources:build_fqdn(namespace)
  local fqdn = ""

  if self.is_namespaced then
    if self.namespace ~= nil then
      fqdn = fqdn .. "namespaces/" .. self.namespace .. "/"
    elseif namespace ~= nil then
      fqdn = fqdn .. "namespaces/" .. namespace .. "/"
    end
  end

  fqdn = fqdn .. self.kind

  return fqdn
end

---@param fqdn string
function KubernetesResources:build_url(fqdn)
  return resources_util.path_mapper(self.api_group) .. "/" .. fqdn
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

---@param metadata KubernetesObjectMeta
---@return CurlResponse|nil
function KubernetesResources:delete(metadata)
  return client.delete(self:build_url(self:build_fqdn(metadata.namespace)) .. "/" .. metadata.name)
end

return KubernetesResources
