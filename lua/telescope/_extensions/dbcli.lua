local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')

local query_utils = require('telescope._extensions.dbcli.query_utils')
local finder_utils = require('telescope._extensions.dbcli.finder_utils')

local pgcli = {}
local mssql_cli = {}
local on_query_select = {}

local M = {}

local dbcli_picker = function(cli_opts)
  local query_list = query_utils.query_list(cli_opts.history_file)
  local sorted_state = {
    last_seen_query_time = 0,
    last_seen_query_index = 0,
    prompt_set_on_last_run = false
  }

  pickers.new({}, {
    prompt_title = cli_opts.prompt_title,
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
      return finder_utils.mappings(prompt_bufnr, on_query_select)
    end,
  }):find()
end

M.pgcli_picker = function()
  return dbcli_picker(pgcli)
end

M.mssql_cli_picker = function()
  return dbcli_picker(mssql_cli)
end

return telescope.register_extension {
 setup = function(ext_config)
    pgcli = ext_config.pgcli or {
      prompt_title = "Pgcli History",
      history_file = os.getenv("HOME").."/.config/pgcli/history"
    }
    mssql_cli = ext_config.mssql_cli or {
      prompt_title = "Mssqlcli History",
      history_file = os.getenv("HOME").."/.config/mssqlcli/history"
    }
    on_query_select = ext_config.on_query_select or {
      open_in_scratch_buffer = true,
      add_query_to_register = false
    }
  end,
  exports = {
    pgcli = M.pgcli_picker,
    mssql_cli = M.mssql_cli_picker
  },
}
