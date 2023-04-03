local curl = require("plenary.curl")
local iterators = require("plenary.iterators")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local proxy = require("k8s.api.proxy")

local M = {}

M.list = function()
    if proxy.started == false then
        proxy.start()
    end

    vim.wait(1000, function()
        return proxy.port ~= nil
    end, 100)

    local url = "localhost:" .. tostring(proxy.port) .. "/api/v1/namespaces"
    local res = curl.get(url)

    if res ~= nil then
        local data = vim.fn.json_decode(res.body)

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
                }),
                sorter = conf.generic_sorter(),
                attach_mappings = function(prompt_bufnr, _map)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        print(selection.value)
                    end)
                    return true
                end,
            })
            :find()
    end
end

return M
