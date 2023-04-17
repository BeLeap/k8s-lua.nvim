local Job = require("plenary.job")
local uv = require("luv")

---@class ApiProxy
---@field public started boolean
---@field public port string|nil
---@field public context string|nil
---@field private handle Job|nil
local ApiProxy = {
    started = false,
    handle = nil,
    port = nil,
    context = nil,
}

---@param context string
function ApiProxy:new(context)
    self.context = context

    return self
end

function ApiProxy:start()
    self.handle = Job:new({
        command = "kubectl",
        args = {
            "--context=" .. self.context,
            "proxy",
            "--port=0",
        },
        on_stdout = function(_error, data)
            local splitted_data = vim.split(data, ":")
            self.port = splitted_data[2]
        end,
    })
    self.handle:start()
    self.started = true

    vim.api.nvim_create_autocmd("VimLeavePre", { callback = self.shutdown })
end

function ApiProxy:shutdown()
    if self.started == true then
        self.handle:shutdown()
        uv.kill(self.handle.pid, 3)

        self.started = false
        self.handle = nil
        self.port = nil
    end
end

return ApiProxy
