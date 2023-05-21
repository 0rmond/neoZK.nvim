local utils = require("neoZK.utils")
local api = vim.api

---Options to use when opening a window.
-- @param opts: Equivalent to keys of "config" parameter of "nvim_open_win". Use :h nvim_open_win to find out more.
local function create_window_options(opts)
    return {
        relative = (opts and opts.relative) or "editor",
        win = (opts and opts.relative == "win" and opts.win) or nil,
        anchor = (opts and opts.anchor) or "NW",
        width = opts.width,
        height = opts.height,
        bufpos = (opts and opts.relative == "win" and opts.bufpos) or nil,
        row = opts.row,
        col = opts.col,
        style = "minimal", --currently only accepts one value
        border = (opts and opts.border) or "rounded",
        title = (opts and opts.title) or "",
        title_pos = (opts and opts.title and opts.title_pos) or "center",
    }
end

local function get_any_linked_window_buffers(win_buf)
    local no_err, res = pcall(api.nvim_buf_get_var, win_buf, "linked_buffer")
    return no_err and res or {}
end

---Stores buffer IDs in a buffer variable for windows that exist in seperate buffers.
-- @param target_buf: Window's buffer ID that will have its "linked_buffers" buffer variable set.
-- @param bufs_to_link: {buffer_IDs}
-- @returns: nothing
local function link_window_buffers(target_buf, bufs_to_link)
    --[[Stores buffer IDs in a buffer variable for windows in separate buffers.
    --]]
    local currently_linked_buffers = get_any_linked_window_buffers(target_buf)

    local linked_buffers = utils.join(currently_linked_buffers, bufs_to_link)
    local unique_buffer_ids = utils.unique(utils.join(currently_linked_buffers, linked_buffers))
    api.nvim_buf_set_var(target_buf, "linked_buffer", unique_buffer_ids)
end

local function set_as_neozk_window(target_buf)
    api.nvim_buf_set_var(target_buf, "neoZK", true)
end

local function check_if_plugin_window(target_buf)
    return pcall(api.nvim_buf_get_var, target_buf, "neoZK") == true
end

return {
    create_window_options = create_window_options,
    get_any_linked_window_buffers = get_any_linked_window_buffers,
    link_window_buffers = link_window_buffers,
    set_as_neozk_window = set_as_neozk_window,
    check_if_plugin_window = check_if_plugin_window,
}
