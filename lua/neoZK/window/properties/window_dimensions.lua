local utils = require("neoZK.utils")
local api = vim.api
local fun = require("fun")

local function calculate_terminal_dimensions()
    -- returns {width, height}
    return {api.nvim_get_option("columns"), api.nvim_get_option("lines")}
end

local function calculate_container_dimensions(fraction, terminal_dimensions)
    return fun.totable(fun.map(
        function(t_dim)
            return math.floor(t_dim * fraction)
        end,
        terminal_dimensions))
end

---
-- @return: {x,y} position of the top-left of the container inside of the terminal
local function calculate_container_position(terminal_dimensions, container_dimensions)
    local col, row =  unpack(fun.totable(fun.map(function(t_dim, c_dim) return (t_dim - c_dim)/2 end, fun.zip(terminal_dimensions, container_dimensions))))

    return {row = row, col = col}
end

local GOLDEN_RATIO = (1 + math.sqrt(5)) / 2
---Subdivides a rectangle into two smaller rectangles according to the golden ratio.
-- @global_param: GOLDEN_RATIO
-- @param container_dimensions: {width,height} of rectangle to subdivide.
-- @param subdivide_direction: "h" or "v" - direction to subdivide the rectangle in.
-- @returns: width, height of {{larger subdiv}, {smaller subdiv}}
local function golden_divide(container_dimensions, subdivide_direction)
    local width = container_dimensions.width or container_dimensions[1]
    local height = container_dimensions.height or container_dimensions[2]

    local subdiv_dim = (subdivide_direction == "h" and width) or (subdivide_direction == "v" and height)

    local larger_subdiv = math.floor( 0.5 + subdiv_dim / GOLDEN_RATIO )
    local smaller_subdiv = math.floor( 0.5 + subdiv_dim / GOLDEN_RATIO^2 )

    if subdivide_direction == "h" then
        return {{width = larger_subdiv, height = height}, {width = smaller_subdiv, height = height}}
    else --[[ if subdivide_direction is vertical then --]]
        return {{width = width, height = larger_subdiv}, {width = width, height = smaller_subdiv}}
    end
end

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

local function calculate_window_anchor_position(container_position, window_height_or_width)
    return container_position + window_height_or_width
end

return {
    calculate_terminal_dimensions = calculate_terminal_dimensions,
    calculate_container_dimensions = calculate_container_dimensions,
    calculate_container_position = calculate_container_position,
    golden_divide = golden_divide,
    create_window_options = create_window_options,
}
