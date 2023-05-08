--[[ functions which involve constructing windows to display or interact with information

1. Measure the dimensions of the terminal.
2. Calculate the dimensions that the container will be as a fraction of the terminal's dimensions.
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
    space_priority = "primary",
}

local RESULTS = {
    title = "results",
    borders = {'╭','─','╮','│',' ','│','╰','─','╯'},
    border_width = 1,
    maximum_content_height = 1,
    space_priority = "secondary",
}

local PROMPT = {
    title = "search",
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
---subdivides a rectangle into two smaller rectangles according to the golden ratio.
-- @global_param: GOLDEN_RATIO
-- @param container_dimensions: {width,height} of rectangle to subdivide.
-- @returns: width, height of {{larger subdiv}, {smaller subdiv}}
local function golden_divide(container_dimensions)
    local width, height = unpack(container_dimensions)
    local largest_dim = math.max(width, height)

    local larger_subdiv = math.floor(0.5 + largest_dim / GOLDEN_RATIO )
    local smaller_subdiv = math.floor(0.5 + largest_dim / GOLDEN_RATIO^2 )

    if width > height then
        return {{larger_subdiv, height}, {smaller_subdiv, height}}
    else return {{width, larger_subdiv}, {width, smaller_subdiv}}
    end
end

--- cba to make a better sorting function rn
local function sort_by_priority(windows)
    local primary = fun.filter(function(win) return win.space_priority == "primary" and win end, windows):totable()
    local secondary = fun.filter(function(win) return win.space_priority == "secondary" and win end, windows):totable()
    local tertiary = fun.filter(function(win) return win.space_priority == "tertiary" and win end, windows):totable()

    return utils.join(tertiary, utils.join(primary, secondary))
end

local function subdivide_container_into_windows(windows, container_dimensions, ...)
    -- for each windows
    --  golden divide the window into two parts: large part = window dimension
    --      golden divide smaller window
    if #windows == 0 then return {...} end

    local subdivided_container = golden_divide(container_dimensions)
    local remaining_subdivides = {unpack(windows, 2, #windows)}
    local container_to_further_subdivide =  subdivided_container[1]
    return subdivide_container_into_windows(remaining_subdivides, container_to_further_subdivide, subdivided_container, ...)
end

local term_dim = calculate_terminal_dimensions()
local cont_dim = calculate_container_dimensions(0.8, term_dim)

local windows = {PREVIEW, PROMPT, RESULTS, SEARCH}
local sorted_wins = sort_by_priority(windows)
test = subdivide_container_into_windows(sorted_wins, cont_dim)
vim.print(test)
