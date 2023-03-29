local Job = require("plenary.job")
local uv = require("luv")

-- @field proxy table
--        - _handle: Job
--        - port: number
local M = {
    proxy = {},
}

M.start = function()
    M.proxy._handle = Job:new({
        command = "kubectl",
        args = {
            "proxy",
            "--port=0",
        },
        on_stdout = function(_error, data)
            local splitted_data = vim.split(data, ":")
            M.proxy.port = splitted_data[2]
        end,
    })
    M.proxy._handle:start()
end

M.shutdown = function()
    if M.proxy._handle ~= nil then
        uv.kill(M.proxy._handle.pid, 3)
        M.proxy = {}
    end
end

M.setup = function(_config)
    vim.api.nvim_create_autocmd("VimLeavePre", { callback = M.shutdown })
end

return M
