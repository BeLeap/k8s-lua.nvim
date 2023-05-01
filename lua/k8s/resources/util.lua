local M = {}

---@param api_group string
---@return string
M.path_mapper = function(api_group)
  if api_group == "core" then
    return "/api/v1"
  else
    return "/apis/" .. api_group
  end
end

return M
