local win_act = require("neoZK.window.action_windows")
local api = vim.api
local fun = require("fun")

local function main()
    local windows = require("neoZK.window.properties").generate_window_properties()
    fun.for_each(
        function(window)
            win_act.open_window(unpack(window))
        end,
        windows
    )
end

return { spawn_all_windows = main }
