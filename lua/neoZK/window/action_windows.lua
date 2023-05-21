local api = vim.api
local win_opts = require("neoZK.window.properties.window_options")
local fun = require("fun")

local function get_hovered_window_buffer()
    return api.nvim_win_get_buf(0)
end

---Opens a window.
-- @param window_buffer: Int - Window's buffer ID.
-- @param enter_when_opened: Bool - Make the current window.
-- @param window_options: {option: value}.
local function open_window(window_buffer, enter_when_opened, window_options)
    api.nvim_open_win(window_buffer, enter_when_opened, window_options)
end

---Closes a specified window (or the hovered window is nothing is specified) and any linked windows.
-- @param target_window: Int - Buffer ID of window to close.
local function close_window(target_window)
    local buffer = target_window or get_hovered_window_buffer()
    local window_is_not_plugin_window = not win_opts.check_if_plugin_window(buffer)

    if window_is_not_plugin_window then return end

    fun.for_each(
        function(linked_buffer)
            api.nvim_buf_delete(linked_buffer, {force = true})
        end,
        win_opts.get_any_linked_window_buffers(buffer)
    )
end

return {
    open_window = open_window,
    close_window = close_window,
}
