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

local M = {}

function M.pgcli_picker(opts)
  opts = opts or {}

  local default_file_path = os.getenv("HOME").."/.config/pgcli/history"
  local query_list = query_utils.query_list(default_file_path)
  local sorted_state = {
    last_seen_query_time = 0,
    last_seen_query_index = 0,
    prompt_set_on_last_run = false
  }

  pickers.new(opts, {
    prompt_title = 'Pgcli History',
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

return telescope.register_extension {
  exports = {
    pgcli = M.pgcli_picker
  },
}
