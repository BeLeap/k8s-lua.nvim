local M = {}

-- @param kind string
-- @param name string
-- @param data table
-- @param au_options table
-- @return buffer_handle
M.create = function(kind, name, data, on_write)
    local buffer = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_option(buffer, "ft", "lua")
    vim.api.nvim_buf_set_name(buffer, "k8s://" .. kind .. "/" .. name)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.fn.split(tostring(vim.inspect(data)), "\n"))
    vim.api.nvim_buf_set_option(buffer, "buftype", "")

    local buffer_option = {
        buffer = buffer,
    }
    local opts = vim.tbl_deep_extend("keep", au_opts or {}, {
        callback = function(ev)
            on_write(ev)
            vim.api.nvim_buf_delete(buffer, { force = true })
        end,
    })
    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, opts)

    return buffer
end

return M
