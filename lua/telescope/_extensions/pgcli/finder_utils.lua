local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local putils = require('telescope.previewers.utils')

local M = {}

local query_entry_to_table = function(query_entry)
  local date = query_entry.display:match("%d+-%d+-%d+")
  local time = query_entry.display:match("%d+:%d+:%d+%.%d+")

  local date_parts = vim.fn.split(date, "-")
  local time_parts = vim.fn.split(time, ":")

  local entry_time = os.time({
    year = date_parts[1],
    month = date_parts[2],
    day = date_parts[3],
    hour = time_parts[1],
    minute = time_parts[2],
    second = time_parts[3]
  })

  return {
    date = date,
    time = time,
    entry_time = entry_time
  }
end

local score_query_list_by_prompt_value = function(prompt, entry, scoring_state)
  local query = query_entry_to_table(entry)

  if entry.query:lower():match(prompt:lower()) then
    local new_state = {
      last_seen_query_time = query.entry_time,
      last_seen_query_index = scoring_state.last_seen_query_index - 1,
      prompt_set_on_last_run = scoring_state.prompt_set_on_last_run
    }

    return scoring_state.last_seen_query_index, new_state
  end

  -- if entry.query:lower():match("["..prompt:lower().."]") == nil then
  return -1, scoring_state
  -- end

  -- return scoring_state.last_seen_query_index + 1, scoring_state
end

local score_query_list_by_date = function(entry, scoring_state)
  local query = query_entry_to_table(entry)

  if query.date == nil then
    return -1, scoring_state
  end

  if query.entry_time >= scoring_state.last_seen_query_time then
    local new_state = {
      last_seen_query_time = query.entry_time,
      last_seen_query_index = scoring_state.last_seen_query_index - 1,
      prompt_set_on_last_run = scoring_state.prompt_set_on_last_run
    }

    return scoring_state.last_seen_query_index, new_state
  end
end

M.scoring_function = function(prompt, entry, scoring_state)
  if prompt == "" then
    if scoring_state.prompt_set_on_last_run then
      local updated_state = {
        last_seen_query_time = 0,
        last_seen_query_index = 0,
        prompt_set_on_last_run = false
      }

      return score_query_list_by_date(entry, updated_state)
    end

    return score_query_list_by_date(entry, scoring_state)
  elseif prompt ~= "" and not scoring_state.prompt_set_on_last_run then
    local updated_state = {
      last_seen_query_time = 0,
      last_seen_query_index = 0,
      prompt_set_on_last_run = true
    }

    return score_query_list_by_prompt_value(prompt, entry, updated_state)
  else
    return score_query_list_by_prompt_value(prompt, entry, scoring_state)
  end
end

M.entry_maker = function(line, query_list)
  return {
    value = line.content,
    ordinal = line.name,
    query = line.query_string,
    display = line.name,
    preview_command = function(entry, bufnr)
      vim.api.nvim_buf_set_virtual_text(bufnr, 0, 0, { { query_list[entry.index].timestamp, 'Comment' }} ,{})
      vim.api.nvim_buf_set_lines(bufnr, 1, -1, true, query_list[entry.index].content)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
      putils.highlighter(bufnr, 'sql')
    end
  }
end

M.mappings = function(bufnr)
  actions.select_default:replace(function(_, _)
    local content = action_state.get_selected_entry().value
    local query = vim.fn.join(content, "\n")
    actions.close(bufnr)

    -- TODO: I think it may be more useful to open a new buffer, with the SQL ft rather than
    -- just copy it?
    if query then
      local cmd="call setreg(v:register,'"..query.."')";
      vim.cmd(cmd)

      print("Query copied")
    end
  end)

  return true
end

return M
