---@class KubernetesObject
---@field metadata KubernetesObjectMeta

---@class KubernetesObjectMeta
---@field name string
---@field namespace string|nil

---@class Resources
---@field public kind string
---@field public get fun(self: Resources, name: string): KubernetesObject|nil
---@field public list fun(self: Resources): KubernetesObject[]|nil
---@field public patch fun(self: Resources, target: KubernetesObjectMeta, data: string): KubernetesObject|nil

---@class Pod: KubernetesObject
---@field kind "status"
---@field status PodStatus

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
