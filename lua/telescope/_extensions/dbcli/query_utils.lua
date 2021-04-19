local M = {}

local build_query_object = function(query_line)
  local timestamp = query_line[1]:gsub("#", ""):gsub("^%s", "")

  table.remove(query_line, 1)
  local content = {}

  for k, v in pairs(query_line) do
    content[k] = v:gsub("^+", "")
  end

  local full_query_string = vim.fn.join(content, " ")
  local title = full_query_string
  local hide_query = false
  local name = timestamp

  if title ~= nil then
    name = timestamp .. " " .. title

    if title:find("^%s?exit") ~= nil or title:find("%\\[dl]") ~= nil then
      hide_query = true
    end
  end

  return {
    name = name,
    query_string = full_query_string,
    timestamp = timestamp,
    hideable_query = hide_query,
    content = content
  }
end

local read_history_file = function(file_path)
  local history_file = io.open(file_path, "rb")

  if not history_file then
    print("Unable to locate: " .. file_path)
    return nil
  end

  local content = history_file:read "*a"
  history_file:close()

  return content
end

M.query_list = function(history_file)
  local query_objects = vim.fn.split(read_history_file(history_file), "\n\n")
  local queries = {}

  for _,v in pairs(query_objects) do
    local query_line = vim.fn.split(v, "\n")
    local query = build_query_object(query_line)

    if not query.hideable_query then
      queries[#queries+1] = query
    end
  end

  return queries
end

return M
