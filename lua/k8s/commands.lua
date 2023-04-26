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
        complete = function(arglead, _line)
          local resources = { "context", "namespace", "pod", "deployment", "statefulset", "service" }

          local match = {}
          if arglead ~= nil then
            for _, resource in ipairs(resources) do
              if vim.startswith(resource, arglead) then
                table.insert(match, resource)
              end
            end
          else
            match = resources
          end

          return match
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
  },
}

M.setup = function()
  for _, command in ipairs(M.commands) do
    local opts = vim.tbl_extend("force", command.opts, { force = true })
    vim.api.nvim_create_user_command(command.name, command.command, opts)
  end
end

return M
