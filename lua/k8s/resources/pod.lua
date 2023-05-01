local client = require("k8s.api.client")
local KubernetesResources = require("k8s.resources")
local config = require("k8s.config")

---@class PodResources: KubernetesResources
local PodResources = {}

---@return PodResources
function PodResources:new(...)
  ---@type PodResources
  local o = {}
  o = vim.deepcopy(self)
  o = vim.tbl_deep_extend("keep", o, KubernetesResources:new(...))

  return o
end

---@param object Pod
function PodResources:get_log(object)
  local name = object.metadata.name
  local containers = vim.list_extend(object.spec.initContainers or {}, object.spec.containers or {})

  local result = {}
  for _, container in ipairs(containers) do
    result[container.name] =
      client.get_raw_body(self:build_url(self:build_fqdn(object.metadata.namespace)) .. "/" .. name .. "/" .. "log", {
        container = container.name,
        tailLines = tostring(config.resources.pod.log.max_lines),
      })
  end

  return result
end

return PodResources
