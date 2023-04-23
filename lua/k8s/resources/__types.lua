---@class KubernetesObject
---@field metadata KubernetesObjectMeta

---@class KubernetesObjectMeta
---@field name string
---@field namespace string|nil

---@class Resources
---@field public kind string
---@field public get fun(self: Resources, name: string): KubernetesObject
---@field public list fun(self: Resources): KubernetesObject[]
---@field public patch fun(self: Resources, target: KubernetesObjectMeta, data: string): KubernetesObject
