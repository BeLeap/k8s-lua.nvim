local kube_config = require("k8s.kube_config")
local Job = require("plenary.job")

---@class ContextResources: Resources
local ContextResources = {}

function ContextResources:build_fqdn()
  return "contexts"
end

-- get current context
---@return string|nil
ContextResources.get_current = function()
  local current = ""
  Job:new({
    command = "kubectl",
    args = {
      "config",
      "current-context",
    },
    on_stdout = function(_error, data)
      current = data
    end,
  }):sync()
  return current
end

-- get list of contexts
---@return KubernetesObject[]|nil
function ContextResources:list()
  ---@type KubernetesObject[]
  local contexts = {}
  Job:new({
    command = "kubectl",
    args = {
      "config",
      "get-contexts",
      "-o",
      "name",
    },
    on_stdout = function(_error, data)
      table.insert(contexts, {
        metadata = {
          name = data,
        },
      })
    end,
  }):sync()

  return contexts
end

return ContextResources
