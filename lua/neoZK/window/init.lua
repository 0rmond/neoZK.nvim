local win_act = require("neoZK.window.action_windows")
local api = vim.api
local fun = require("fun")

local function spawn_all_windows()
    local windows = require("neoZK.window.properties").generate_window_properties()

    fun.for_each(
        function(window)
            win_act.open_window(unpack(window))
        end,
        windows
    )
    return fun.totable(fun.map(
        function(window)
            return window[1]
        end,
        windows
    ))
end


local function main(window_id_to_close)

    -- remove any previous triggers of VimResized to keep the next trigger fast
    api.nvim_command("autocmd! VimResized")

    if window_id_to_close then win_act.close_window(window_id_to_close) end

    local window_ids = spawn_all_windows()
    api.nvim_create_autocmd("VimResized", {
        nested = true,
        callback = function() main(window_ids[1]) end,
    })
end

return { spawn_all_windows = main }
