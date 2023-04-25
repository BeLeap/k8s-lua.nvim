local client = require("k8s.api.client")
local KubernetesResources = require("k8s.resources")

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

---@param metadata KubernetesObjectMeta
function PodResources:get_log(metadata)
    local name = metadata.name

    return client.get_raw_body(self.api_prefix .. "/" .. name .. "/" .. "log")
end

return PodResources
