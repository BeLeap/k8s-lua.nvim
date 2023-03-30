local Job = require("plenary.job")
local uv = require("luv")

-- @field started boolean
-- @field _handle Job|nil
-- @field port string|nil
local M = {
    started = false,
    _handle = nil,
    port = nil,
}

M.start = function()
    M._handle = Job:new({
        command = "kubectl",
        args = {
            "proxy",
            "--port=0",
        },
        on_stdout = function(_error, data)
            local splitted_data = vim.split(data, ":")
            M.port = splitted_data[2]
        end,
    })
    M._handle:start()
    M.started = true
end

M.shutdown = function()
    if M.started == true then
        M._handle:shutdown()
        uv.kill(M._handle.pid, 3)

        M.started = false
        M._handle = nil
        M.port = nil
    end
end

M.setup = function(_config)
    vim.api.nvim_create_autocmd("VimLeavePre", { callback = M.shutdown })
end

return M
