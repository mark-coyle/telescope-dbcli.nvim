# telescope-pgcli.nvim
Basic pgcli query history viewer support with telescope

![telescope-pgcli.nvim](https://github.com/mark-coyle/images/blob/master/telescope-pgcli.png?raw=true)

## Dependencies

This plugin will only work on Neovim nightly (0.5).
It also assumes you are already using the popular telescope plugin which can be found [here](https://github.com/nvim-telescope/telescope.nvim)
and that you are using _some_ of the dbcli tools i.e. [pgcli](https://github.com/dbcli/pgcli), [mssql-cli](https://github.com/dbcli/mssql-cli)

## Installation

Using your preferred plugin manager ( Packer and vim-plug for example )

```lua
-- Packer
use { 'mark-coyle/telescope-pgcli.nvim' }

-- Plug
Plug 'mark-coyle/telescope-pgcli.nvim'
```

Run your plugin managers installer `:PackerSync/:PlugInstall`

Then load the extension in your lua/viml config

```lua
-- in lua
require('telescope').load_extension('pgcli')
```

```viml
-- in vimscript
:lua require('telescope').load_extension('pgcli')
```

## Usage

After installing, you should now be able to run `:Telescope pgcli` or you can map it as you like using something like

```
:lua require('telescope').extensions.pgcli.pgcli()
:lua require('telescope').extensions.pgcli.mssql_cli()
```

## Config

As it happens, `pgcli` and `mssql-cli` have history files that share a format, the same underlying picker logic works for both.
As such, you can define the history file path and the prompt title for none, either or both in the telescope extension config.

The defaults for the following config options are the values used in the example, should you need to change the defaults, you can override them like so:

```lua
require('telescope').setup {
  extensions = {
    pgcli = {
      pgcli_prompt_title = 'Pgcli History'
      pgcli_history_file = os.getenv('HOME') .. "/.config/pgcli/history",
      mssql_cli_prompt_title = 'Mssql-cli History'
      mssql_cli_history_file = os.getenv('HOME') .. "/.config/mssql-cli/history",
      on_query_select = {
        open_in_scratch_buffer = true,
        add_query_to_register = false
      }
    }
  }
}
```
