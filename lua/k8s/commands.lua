local global_contexts = require("k8s.global_contexts")
local autocompleter = require("k8s.autocompleter")
local aliases = {
  ["context"] = {
    "ctx",
    "contexts",
  },
  ["namespace"] = {
    "ns",
    "namespaces",
  },
  ["pod"] = {
    "po",
    "pods",
  },
  ["deployment"] = {
    "deploy",
    "deployments",
  },
  ["statefulset"] = {
    "sts",
    "statefulsets",
  },
  ["service"] = {
    "svc",
    "services",
  },
}

local lookup_table = {}

local gen_lookup_table = function()
  for k, alias in pairs(aliases) do
    for _, v in ipairs(alias) do
      lookup_table[v] = k
    end
  end
end

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
          end
        end,
      },
      command = function(opts)
        if opts.args == "" then
          print("k8s-lua.nvim: argument required!")
          return
        end

        local module_found, ui = pcall(require, "k8s.ui." .. opts.args)

        if not module_found then
          if vim.tbl_isempty(lookup_table) then
            gen_lookup_table()
          end

          ui = require("k8s.ui." .. lookup_table[opts.args])
        end
        ui.select()
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
