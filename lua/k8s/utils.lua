local M = {}

M.readfile = function(target_path)
    return M.join_to_string(vim.fn.readfile(target_path))
end

M.join_to_string = function(data)
    local content = {}

    for _, value in ipairs(data) do
        content[#content + 1] = tostring(value)
    end

    return table.concat(content, "\n")
end

M.union = function(list1, list2)
    local result = {}
    local hash = {}

    -- add items from list1
    for _, item in ipairs(list1) do
        if not hash[item] then
            table.insert(result, item)
            hash[item] = true
        end
    end

    -- add items from list2
    for _, item in ipairs(list2) do
        if not hash[item] then
            table.insert(result, item)
            hash[item] = true
        end
    end

    return result
end

---@class Diff
---@field op string
---@field path string
---@field value string|nil

---@param original any
---@param new any
---@return Diff[]
M.calculate_diffs = function(original, new)
    if type(original) ~= "table" or type(new) ~= "table" then
        local diff = {
            path = "",
        }

        if new ~= nil then
            diff.value = new
        end

        if original ~= nil and new ~= nil then
            diff.op = "replace"
        elseif original ~= nil and new == nil then
            diff.op = "remove"
        elseif original == nil and new ~= nil then
            diff.op = "add"
        end

        return { diff }
    end

    local original_keys = vim.tbl_keys(original)
    local new_keys = vim.tbl_keys(new)
    local keys = M.union(original_keys, new_keys)

    local diffs = {}
    for _, key in ipairs(keys) do
        if not vim.deep_equal(original[key], new[key]) then
            local sub_diffs = M.calculate_diffs(original[key], new[key])

            for _, sub_diff in ipairs(sub_diffs) do
                sub_diff.path = "/" .. key .. sub_diff.path

                table.insert(diffs, sub_diff)
            end
        end
    end

    return diffs
end

return M
