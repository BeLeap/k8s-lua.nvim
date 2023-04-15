local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

local utils = require("k8s.utils")
local detail = require("k8s.ui.pickers.detail")

---@class ResourceEntry
---@field value KubernetesObject
---@field display string
---@field ordinal string

---@class ResourcesPicker
---@field private resources NamespacedResource
---@field private result table
---@field public picker Picker
local ResourcesPicker = {}

function ResourcesPicker:edit_action(prompt_bufnr)
    return function()
        ---@type ResourceEntry
        local selection = action_state.get_selected_entry()

        local buffer = detail.create(self.resources.kind, selection.value, function(ev)
            if self.resources.patch ~= nil then
                local content_raw = utils.join_to_string(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false))
                local content = load("return " .. content_raw)()
                local diff = utils.calculate_diffs(selection.value, content)

                self.resources:patch(selection.value.metadata, vim.json.encode(diff))
            end
        end)

        actions.close(prompt_bufnr)
        vim.api.nvim_set_current_buf(buffer)
    end
end

function ResourcesPicker:preview_opts_factory()
    return {
        title = "detail",
        dyn_title = function(_, entry)
            return "detail - " .. entry.display
        end,
        define_preview = function(preview, entry, _status)
            vim.api.nvim_buf_set_option(preview.state.bufnr, "ft", "lua")
            vim.api.nvim_buf_set_lines(
                preview.state.bufnr,
                0,
                -1,
                false,
                vim.fn.split(tostring(vim.inspect(entry.value)), "\n")
            )
        end,
    }
end

---@param resources NamespacedResource
---@param when_select function|nil
---@param is_current function|nil
function ResourcesPicker:new(resources, when_select, is_current)
    vim.validate({
        resources = { resources, "table" },
    })

    self.resources = resources
    self.results = self.resources:list_iter():tolist()

    local guarded_when_select = when_select or function(_selection) end
    local guarded_is_current = is_current or function(_elem)
        return false
    end

    local default_selection_index = 0
    for i, elem in ipairs(self.results) do
        if guarded_is_current(elem) then
            default_selection_index = i
        end
    end

    self.picker = pickers.new({}, {
        prompt_title = self.resources.kind,
        finder = finders.new_table({
            results = self.results,
            entry_maker = function(entry)
                ---@type ResourceEntry
                local resource_entry = {
                    value = entry,
                    display = entry.metadata.name,
                    ordinal = entry.metadata.name,
                }

                return resource_entry
            end,
        }),
        default_selection_index = default_selection_index,
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            map("n", "e", self:edit_action(prompt_bufnr))

            actions.select_default:replace(function()
                actions.close(prompt_bufnr)

                ---@type ResourceEntry
                local selection = action_state.get_selected_entry()
                guarded_when_select(selection)
            end)

            return true
        end,
        previewer = previewers.new_buffer_previewer(self:preview_opts_factory()),
    })

    return self
end

return ResourcesPicker
