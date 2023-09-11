" This config is used by the plenary testing framework.
" run the following to run the tests:
" nvim --headless -c "PlenaryBustedDirectory ./ { minimal_init = 'minimal_config.vim' }"
set rtp+=.
set rtp+=..
set rtp+=/home/oft507/.local/share/nvim/lazy/plenary.nvim/

runtime! plugin/plenary.vim
runtime! plugin/init.lua
