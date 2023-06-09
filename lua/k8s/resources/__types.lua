---@class KubernetesObject
---@field metadata KubernetesObjectMeta

---@class KubernetesObjectMeta
---@field name string
---@field namespace string|nil

---@class Resources
---@field public kind string
---@field public api_group string
---@field public is_namespaced boolean
---@field public namespace string|nil
---@field public build_fqdn fun(self: Resources, namespace: string|nil): string
---@field public get ((fun(self: Resources, name: string): KubernetesObject|nil)|nil)
---@field public list fun(self: Resources): KubernetesObject[]|nil
---@field public patch ((fun(self: Resources, metadata: KubernetesObjectMeta, data: string): KubernetesObject|nil)|nil)
---@field public delete ((fun(self: Resources, metadata: KubernetesObjectMeta): CurlResponse|nil)|nil)

---@class Pod: KubernetesObject
---@field kind "Pod"
---@field status PodStatus
---@field spec PodSpec

---@class PodSpec
---@field initContainers Container[]
---@field containers Container[]

---@class Container
---@field name string

---@class PodStatus
---@field phase
---| "Pending"
---| "Running"
---| "Succeeded"
---| "Failed"
---| "Unknown"
---@field conditions PodCondition[]

---@class PodCondition
---@field type string
---@field status
---| "True"
---| "False"
---| "Unknown"

---@class Deployment: KubernetesObject
---@field kind "Deployment"
---@field status DeploymentStatus

---@class DeploymentStatus
---@field replicas integer
---@field readyReplicas integer
