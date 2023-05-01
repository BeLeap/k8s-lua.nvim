local global_contexts = require("k8s.global_contexts")
local autocompleter = require("k8s.autocompleter")
local resources = require("k8s.resources")
local available = require("k8s.resources.available")
local pickers = require("k8s.ui.pickers")

local predefined = {
  core = {
    contexts = require("k8s.ui.context"),
    namespaces = require("k8s.ui.namespace"),
    pods = require("k8s.ui.pod"),
    services = require("k8s.ui.service"),
  },
  ["apps/v1"] = {
    deployments = require("k8s.ui.deployment"),
    statefulsets = require("k8s.ui.statefulset"),
  },
}

local M = {
  commands = {
    {
      name = "Kube",
      opts = {
        nargs = "*",
        complete = function(arglead, line)
          local args = vim.split(line, " ")

          if #args == 2 then
            return autocompleter.apis_completer(arglead)
          elseif #args == 3 then
            return autocompleter.resources_completer(args[2], arglead)
          else
            return {}
          end
        end,
      },
      command = function(opts)
        if opts.args == "" then
          print("k8s-lua.nvim: argument required!")
          return
        end

        local api_group = opts.fargs[1]
        local kind = opts.fargs[2]

        if predefined[api_group] ~= nil and predefined[api_group][kind] then
          predefined[api_group][kind].select()
        else
          local resource =
            resources:new(kind, api_group, available.is_namespaced(api_group, kind), global_contexts.selected_namespace)

          pickers:new(resource)
        end
      end,
    },
    {
      name = "KubeApply",
      command = function()
        ---@type BufferHandle
        local current_buffer = vim.api.nvim_get_current_buf()
        local contents = table.concat(vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false), "\n")

        local handle = io.popen(
          "kubectl --context="
            .. global_contexts.selected_contexts
            .. " --namespace="
            .. (global_contexts.selected_namespace or "default")
            .. " apply -f - <<EOF\n"
            .. contents
            .. "\nEOF"
        )
        if handle ~= nil then
          local result = handle:read("*a")
          handle:close()

          print(result)
        else
          print("failed to create process.")
        end
      end,
    },
  },
}

M.setup = function()
  for _, command in ipairs(M.commands) do
    local opts = vim.tbl_extend("force", command.opts or {}, { force = true })
    vim.api.nvim_create_user_command(command.name, command.command, opts)
  end
end

return M
