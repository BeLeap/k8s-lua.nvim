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

return M
