local curl = require("plenary.curl")
local iterators = require("plenary.iterators")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local proxy = require("k8s.api.proxy")

local M = {}

M.get = function(namespace)
    vim.validate({
        namespace = { namespace, "string" },
    })

    if proxy.started == false then
        proxy.start()
    end

    vim.wait(1000, function()
        return proxy.port ~= nil
    end, 100)

    local url = "localhost:" .. tostring(proxy.port) .. "/api/v1/namespaces/" .. tostring(namespace)
    local res = curl.get(url)

    if res ~= nil then
        return vim.json.decode(res.body)
    end
end

M.select = function()
    if proxy.started == false then
        proxy.start()
    end

    vim.wait(1000, function()
        return proxy.port ~= nil
    end, 100)

    local url = "localhost:" .. tostring(proxy.port) .. "/api/v1/namespaces"
    local res = curl.get(url)

    if res ~= nil then
        local data = vim.json.decode(res.body)

        local items_iter = iterators.iter(data.items)
        local names_iter = items_iter:map(function(item)
            return item.metadata.name
        end)
        local names = names_iter:tolist()

        pickers
            .new({}, {
                prompt_title = "Namespaces",
                finder = finders.new_table({
                    results = names,
                    entry_maker = function(name)
                        local display = "  " .. name
                        if name == M.target_namespace then
                            display = "* " .. name
                        end

                        return {
                            value = name,
                            display = display,
                            ordinal = name,
                        }
                    end,
                }),
                sorter = conf.generic_sorter(),
                attach_mappings = function(prompt_bufnr, _map)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        M.target_namespace = selection.value
                    end)
                    return true
                end,
                previewer = previewers.new_buffer_previewer({
                    title = "Describe",
                    dyn_title = function(_, entry)
                        return "Describe - " .. entry.value
                    end,
                    define_preview = function(self, entry, _status)
                        local preview_data = M.get(entry.value)
                        vim.api.nvim_buf_set_option(self.state.bufnr, "ft", "lua")
                        vim.api.nvim_buf_set_lines(
                            self.state.bufnr,
                            0,
                            -1,
                            false,
                            vim.fn.split(tostring(vim.inspect(preview_data)), "\n")
                        )
                    end,
                }),
            })
            :find()
    end
end

M.test = function()
    local result = tostring(vim.inspect(M.get("airflow")))
    local bar = vim.fn.split(result, "\n")
    print(vim.inspect(bar))
end

return M
