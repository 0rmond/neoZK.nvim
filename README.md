# neoZK.nvim

## Plugin File

Files in this directory are ran before any other files in the `neoZK.nvim` plugin.
It is ran on runtime.
We can create keymaps and autocommands inside of here.

## Lua directory

Files in this directory must be required to use.
`init.lua` files are automatically loaded when requiring though.


## Misc stuff

`require` loads a file once.
We may need to keep requiring a file!
