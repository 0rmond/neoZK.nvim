--[[ 
-- Functions which involve constructing windows to display or interact with information.
--]]

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
    return fun.totable(fun.map(function(dimension) return dimension/2 end, fun.zip(terminal_dimensions, container_dimensions)))
end
local PREVIEW = {
    title = "preview",
    borders = {'╭','─','╮','│',' ','│','╰','─','╯'},
    border_width = 1,
    minimum_content_width = 20,
}

local RESULTS = {
    title = "results",
    borders = {'╭','─','╮','│',' ','│','╰','─','╯'},
    border_width = 1,
    maximum_content_height = 1,
    space_priority = "secondary",
}

local SEARCHED_TAGS = {
    title = "searched tags",
    borders = {'╭','─','╮','│',' ','│','╰','─','╯'},
    border_width = 1,
    space_priority = "tertiary",
}

local SEARCH = {
    title = "search",
    borders = {'╭','─','╮','│',' ','│','╰','─','╯'},
    border_width = 1,
    space_priority = "tertiary",
}

local GOLDEN_RATIO = (1 + math.sqrt(5)) / 2
---Subdivides a rectangle into two smaller rectangles according to the golden ratio.
-- @global_param: GOLDEN_RATIO
-- @param container_dimensions: {width,height} of rectangle to subdivide.
-- @param subdivide_direction: "h" or "v" - direction to subdivide the rectangle in.
-- @returns: width, height of {{larger subdiv}, {smaller subdiv}}
local function golden_divide(container_dimensions, subdivide_direction)
    local width, height = unpack(container_dimensions)
    local largest_dim = math.max(width, height)

    local larger_subdiv = math.floor(0.5 + largest_dim / GOLDEN_RATIO )
    local smaller_subdiv = math.floor(0.5 + largest_dim / GOLDEN_RATIO^2 )

    if subdivide_direction == "h" then
        return {{larger_subdiv, height}, {smaller_subdiv, height}}
    else --[[ if subdivide_direction is vertical then --]]
        return {{width, larger_subdiv}, {width, smaller_subdiv}}
    end
end

local terminal_dimensions = calculate_terminal_dimensions()
local container_dimensions = calculate_container_dimensions(0.8, terminal_dimensions)

local preview_window, other_windows = golden_divide(container_dimensions, "h")
local results_window, tags_and_search_windows = golden_divide(container_dimensions, "v")
vim.print(container_dimensions)
vim.print(preview_window)
