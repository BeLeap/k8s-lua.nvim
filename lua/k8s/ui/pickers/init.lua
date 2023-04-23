---@class ResourceEntry
---@field value KubernetesObject
---@field display string
---@field ordinal string

---@class ResourcesPicker
---@field private resources Resource
---@field public buffer BufferHandle
local ResourcesPicker = {}

---@param resources Resource
---@param args {}
function ResourcesPicker:new(resources, args)
    self.resources = resources

    local iter = self.resources:list_iter()

    if iter ~= nil then
        local names = iter:map(
            ---@param elem KubernetesObject
            function(elem)
                return elem.metadata.name
            end
        ):tolist()

        self.buffer = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_buf_set_name(self.buffer, "k8s://" .. self.resources.kind)
        vim.api.nvim_buf_set_option(self.buffer, "buftype", "")
        vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, names)
    end

    return self
end

return ResourcesPicker
