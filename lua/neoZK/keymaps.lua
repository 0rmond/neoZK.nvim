local api = vim.api
local make_keymap = vim.keymap.set

local mappings = {
    ["<S-z>"] = require("neoZK.window"),
    ["<Esc>"] = require("neoZK.window.action_windows").close_window,
}

make_keymap('n', "<S-z>", function() require("neoZK.window").spawn_all_windows() end)
make_keymap('n', "<Esc>", function() require("neoZK.window.action_windows").close_window() end)
