---@class Buffer
---@field public buffer BufferHandle
local Buffer = {}

---@return Buffer
function Buffer:new()
    local o = {}
    o = vim.deepcopy(self)

    local buffer = vim.api.nvim_create_buf(false, true)
    o.buffer = buffer

    return o
end

---@param ns NamespaceId
---@param hlgroup string
---@param start { [1]: integer, [2]: integer }
---@param finish { [1]: integer, [2]: integer }
---@param opts table|nil
function Buffer:highlight(ns, hlgroup, start, finish, opts)
    vim.highlight.range(self.buffer, ns, hlgroup, start, finish, opts)
end

---set keymap for picker buffer
---@param mode
---| "n"
---| "i"
---| "v"
---@param key string
---@param action function
---@param opts {}|nil
function Buffer:keymap(mode, key, action, opts)
    local opts_with_buf = vim.tbl_deep_extend("keep", opts or {}, { buffer = self.buffer })

    vim.keymap.set(mode, key, action, opts_with_buf)
end

---@param func_name
---| "nvim_buf_attach"
---| "nvim_buf_delete"
---| "nvim_buf_set_extmark"
---| "nvim_buf_set_lines"
---| "nvim_buf_set_name"
---| "nvim_buf_set_option"
---| "nvim_set_current_buf"
---@param ...any
function Buffer:vim_api(func_name, ...)
    return vim.api[func_name](self.buffer, ...)
end

---@return string
function Buffer:line_under_cursor()
    local cursor_location = vim.api.nvim_win_get_cursor(0)
    return vim.api.nvim_buf_get_lines(self.buffer, cursor_location[1] - 1, cursor_location[1], false)[1]
end

return Buffer
