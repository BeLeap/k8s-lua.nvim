local M = {}

M.previewer_opt_factory = function()
    return {
        title = "Describe",
        dyn_title = function(_, entry)
            return "Describe - " .. entry.display
        end,
        define_preview = function(self, entry, _status)
            local preview_data = entry.value.preview_data_fetcher.call(entry.value.preview_data_fetcher.args)
            vim.api.nvim_buf_set_option(self.state.bufnr, "ft", "lua")
            vim.api.nvim_buf_set_lines(
                self.state.bufnr,
                0,
                -1,
                false,
                vim.fn.split(tostring(vim.inspect(preview_data)), "\n")
            )
            -- end
        end,
    }
end

return M
