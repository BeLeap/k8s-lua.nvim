local M = {}

-- @param kind string
-- @param name string
-- @param data table
-- @param au_options table
-- @return buffer_handle
M.create = function(kind, name, data, au_opts)
    local buffer = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_option(buffer, "ft", "lua")
    vim.api.nvim_buf_set_name(buffer, "/tmp/" .. kind .. "/" .. name)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.fn.split(tostring(vim.inspect(data)), "\n"))
    vim.api.nvim_buf_set_option(buffer, "buftype", "")

    local buffer_option = {
        buffer = buffer,
    }
    print(vim.inspect(au_opts))
    local opts = vim.tbl_deep_extend("keep", au_opts or {}, buffer_option)
    vim.api.nvim_create_autocmd({ "BufWrite" }, opts)

    return buffer
end

return M
