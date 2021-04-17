# telescope-pgcli.nvim
Basic pgcli query history viewer support with telescope

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

## Useage

After installing, you should now be able to run `:Telescope pgcli` or you can map it as you like using something like

```
:lua require('telescope').extensions.pgcli.pgcli()
```

## Config

This extension was written with `pgcli` in mind but in theory it may/should work with any of the other `dbcli` tools provided they use the same history file format as `pgcli`. For instance, I also use `mssql-cli` from time to time and that _is_ in the same format, so, this extension will work for both of those tools.

As such, there are a couple of config options available to make this extension work for other dbcli tools.

`prompt_title` which will be used as the title of the display that telescope renders. This means you can provide strings such as `Pgcli History` or `Mssql-cli History` or any other string that helps you differentiate between the tools.
The default prompt title will be `Pgcli History`.

`history_file` this allows you to supply a path to the query file you wish to load from, which helps in supporting multiple `dbcli` tools.
**NOTE**: The default history file will be `$HOME/.config/pgcli/history`, it is recommended you pass in the correct file path for your machine if it differs.

```lua
:lua require('telescope').extensions.pgcli.pgcli({ prompt_title = 'Pgcli History', history_file = '<your_path_to_pgcli>/pgcli/history' })
:lua require('telescope').extensions.pgcli.pgcli({ prompt_title = 'Mssql-cli History', history_file = '<your_path_to_mssql_cli>/mssql-cli/history' })
```
