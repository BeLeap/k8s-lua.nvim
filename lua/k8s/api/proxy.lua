local Job = require("plenary.job")
local uv = require("luv")
local resources_context = require("k8s.resources.context")

-- @field started boolean
-- @field _handle Job|nil
-- @field port string|nil
-- @field current_context string|nil
local M = {
    started = false,
    _handle = nil,
    port = nil,
    current_context = nil,
}

M.start = function()
    M.current_context = resources_context.target

    M._handle = Job:new({
        command = "kubectl",
        args = {
            "--context=" .. M.current_context,
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

M.update = function()
    if M.started == true and M.current_context == resources_context.target then
        return
    end

    M.shutdown()
    M.start()
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
