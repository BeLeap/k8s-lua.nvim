local M = {}

-- @param kind string
-- @param name string
-- @param data table
-- @return buffer_handle
M.create = function(kind, name, data)
    local buffer = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_option(buffer, "ft", "lua")
    vim.api.nvim_buf_set_name(buffer, kind .. "/" .. name)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.fn.split(tostring(vim.inspect(data)), "\n"))

    return buffer
end

return M
