local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local putils = require('telescope.previewers.utils')

local M = {}

local function read_history_file()
  local history_file = io.open(os.getenv("HOME").."/.config/pgcli/history", "rb")

  if not history_file then
    print("Could not find pgcli history file")
    return nil
  end

  local content = history_file:read "*a"
  history_file:close()

  return content
end

local function build_query_object(query_line)
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

local function get_queries()
  local query_content = read_history_file()
  local query_objects = vim.fn.split(query_content, "\n\n")
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

function M.pgcli_picker(opts)
  opts = opts or {}
  local results = get_queries()

  pickers.new(opts, {
    prompt_title = 'Pgcli History',
    finder = finders.new_table {
      results = results,
      entry_maker = function(line)
        return {
          value = line.content,
          ordinal = line.name,
          query = line.query_string,
          display = line.name,
          preview_command = function(entry, bufnr)
            vim.api.nvim_buf_set_virtual_text(bufnr, 0, 0, { { results[entry.index].timestamp, 'Comment' }} ,{})
            vim.api.nvim_buf_set_lines(bufnr, 1, -1, true, results[entry.index].content)
            vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
            putils.highlighter(bufnr, 'sql')
          end,
        }
      end
    },
    sorter = sorters.fuzzy_with_index_bias(),
    previewer = previewers.display_content.new({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function(_, _)
        local content = action_state.get_selected_entry().value
        local query = vim.fn.join(content, "\n")
        actions.close(prompt_bufnr)

        if query then
          local cmd="call setreg(v:register,'"..query.."')";
          vim.cmd(cmd)

          print("Query copied")
        end
      end)

      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = {
    pgcli = M.pgcli_picker
  },
}
