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

Currently there are no custom options, so all you need to do is load the extensions and map it/use it however you see fit :)

*NOTE* There is an assumption that you `pgcli` history file is located at `$HOME/.config/pgcli/history`
