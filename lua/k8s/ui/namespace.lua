local pickers = require("k8s.ui.pickers")
local resources = require("k8s.resources")

local M = {}

M.select = function()
    local namespace = resources:new("namespaces", "api/v1", false, nil)
    local picker = pickers:new(namespace, {})

    vim.api.nvim_buf_attach(picker.buffer, false, {})
    vim.api.nvim_set_current_buf(picker.buffer)
end

return M
