local global_contexts = require("k8s.global_contexts")
local ResourcePicker = require("k8s.ui.pickers")

---@class NamespacedResourcePicker: ResourcePicker
local NamespacedResourcePicker = {}

---@param resources Resources
---@param args PickerNewArgs|nil
function NamespacedResourcePicker:new(resources, args)
  local modified_args = vim.tbl_extend("keep", {
    entry_modifier = function(buffer, index, object)
      if args ~= nil and args.entry_modifier ~= nil then
        args.entry_modifier(buffer, index, object)
      end

      if resources.is_namespaced and resources.namespace == nil then
        local pod = object --[[@as Pod]]

        buffer:vim_api("nvim_buf_set_extmark", global_contexts.ns_id, index - 1, -1, {
          virt_text = {
            { "@ " .. pod.metadata.namespace, "Comment" },
          },
        })
      end
    end,
  }, args or {})

  return ResourcePicker:new(resources, modified_args)
end

return NamespacedResourcePicker
