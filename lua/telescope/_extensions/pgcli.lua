local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')

local query_utils = require('telescope._extensions.pgcli.query_utils')
local finder_utils = require('telescope._extensions.pgcli.finder_utils')

local pgcli_history_file = ""
local pgcli_prompt_title = ""
local mssql_cli_prompt_title = ""
local mssql_cli_history_file = ""

local M = {}

local dbcli_picker = function(prompt_title, history_file)
  local query_list = query_utils.query_list(history_file)
  local sorted_state = {
    last_seen_query_time = 0,
    last_seen_query_index = 0,
    prompt_set_on_last_run = false
  }

  pickers.new({}, {
    prompt_title = prompt_title,
    finder = finders.new_table {
      results = query_list,
      entry_maker = function(line)
        return finder_utils.entry_maker(line, query_list)
      end
    },
    sorter = sorters.new {
      scoring_function = function(_, prompt, _, entry)
        local sort_value, new_state = finder_utils.scoring_function(prompt, entry, sorted_state)

        sorted_state.last_seen_query_index = new_state.last_seen_query_index
        sorted_state.last_seen_query_time = new_state.last_seen_query_time
        sorted_state.prompt_set_on_last_run = new_state.prompt_set_on_last_run

        return sort_value
      end
    },
    previewer = previewers.display_content.new({}),
    attach_mappings = function(prompt_bufnr)
      return finder_utils.mappings(prompt_bufnr)
    end,
  }):find()
end

M.pgcli_picker = function()
  return dbcli_picker(pgcli_prompt_title, pgcli_history_file)
end

M.mssql_cli_picker = function()
  return dbcli_picker(mssql_cli_prompt_title, mssql_cli_history_file)
end

return telescope.register_extension {
 setup = function(ext_config)
    pgcli_prompt_title = ext_config.pgcli_prompt_title or "Pgcli History"
    pgcli_history_file = ext_config.pgcli_history_file or os.getenv("HOME").."/.config/pgcli/history"
    mssql_cli_prompt_title = ext_config.mssql_cli_prompt_title or "Mssql-cli History"
    mssql_cli_history_file = ext_config.mssql_cli_history_file or os.getenv("HOME").."/.config/mssql-cli/history"
  end,
  exports = {
    pgcli = M.pgcli_picker,
    mssql_cli = M.mssql_cli_picker
  },
}
