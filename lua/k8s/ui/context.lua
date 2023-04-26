local global_contexts = require("k8s.global_contexts")
local resources_context = require("k8s.resources.context")
local pickers = require("k8s.ui.pickers")

local M = {}

-- select context with telescope picker
M.select = function()
  pickers:new(resources_context, {
    on_select = function(selection)
      global_contexts.selected_contexts = selection.name
    end,
    entry_modifier = function(buffer, index, object)
      if object.metadata.name == global_contexts.selected_contexts then
        buffer:vim_api("nvim_buf_set_extmark", global_contexts.ns_id, index - 1, -1, {
          virt_text = {
            { "current", "Comment" },
          },
        })
      end
    end,
  })
end

return M
