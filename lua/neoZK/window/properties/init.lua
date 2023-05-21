local fun = require("fun")
local api = vim.api
local win_dims = require("neoZK.window.properties.window_dimensions")
local win_opts = require("neoZK.window.properties.window_options")

local function calculate_container_dimensions_and_position()
    local terminal_dimensions = win_dims.calculate_terminal_dimensions()
    local container_dimensions = win_dims.calculate_container_dimensions(0.8, terminal_dimensions)
    local container_position = win_dims.calculate_container_position(terminal_dimensions, container_dimensions)

    return {dimensions = container_dimensions, position = container_position}
end

local function subdivide_container(container)
    local preview_window_dims, res_tag_ser_windows_dims = unpack(win_dims.golden_divide(container.dimensions, "h"))
    local results_window_dims, tag_ser_windows_dims = unpack(win_dims.golden_divide(res_tag_ser_windows_dims, "v"))
    local tag_window_dims, search_window_dims = unpack(win_dims.golden_divide(tag_ser_windows_dims, "v"))

    return {
        preview = preview_window_dims,
        results = results_window_dims,
        tag = tag_window_dims,
        search = search_window_dims,
        res_tag_ser = res_tag_ser_windows_dims,
        tag_ser = tag_ser_windows_dims,
    }
end

-- set the options of each window

local function arrange_windows(window_dimensions, container)
    return {
        preview = {
            width = window_dimensions.preview.width - 1,
            height = window_dimensions.preview.height,
            row = container.position.row,
            col = container.position.col + window_dimensions.res_tag_ser.width + 1
        },
        results = {
            width = window_dimensions.results.width - 1,
            height = window_dimensions.results.height - 1,
            row = container.position.row,
            col = container.position.col
        },
        tag = {
            width = window_dimensions.tag.width - 1,
            height = window_dimensions.tag.height - 2,
            row = container.position.row + window_dimensions.results.height + 1,
            col = container.position.col
        },
        search = {
            width = window_dimensions.search.width - 1,
            height = window_dimensions.search.height - 1,
            row = container.position.row + window_dimensions.results.height + window_dimensions.tag.height + 1,
            col = container.position.col
        }
    }
end

local function generate_window_options(window_sizes_and_position)
    return fun.totable(fun.map(
        function(window_name, win_dimensions)
            return win_opts.create_window_options({
                width = win_dimensions.width,
                height = win_dimensions.height,
                row = win_dimensions.row,
                col = win_dimensions.col,
                title = window_name,
            })
        end,
        window_sizes_and_position
    ))
end


-- create a buffer for each window
local function create_win_buff_for_each(windows)
    return fun.totable(fun.map(
        function()
            return api.nvim_create_buf(false, true)
        end,
        windows
    ))
end

-- set buffer variables
local function set_buffer_variables(buffer_ids)
    return fun.for_each(
        function(buf_id)
            win_opts.set_as_neozk_window(buf_id)
            win_opts.link_window_buffers(buf_id, buffer_ids)
        end,
        buffer_ids
    )
end

local function main()
    local container = calculate_container_dimensions_and_position()
    local window_dimensions = subdivide_container(container)

    local window_sizes_and_position = arrange_windows(window_dimensions, container)
    local window_options = generate_window_options(window_sizes_and_position)

    local window_buffers = create_win_buff_for_each(window_options)
    set_buffer_variables(window_buffers)

    return fun.totable(fun.map(
        function(win_buf, win_opt)
            local enter_when_opened = win_opt.title == "Preview" or win_opt.title == "preview"
            return {win_buf, enter_when_opened, win_opt}
        end,
        fun.zip(window_buffers, window_options)
    ))
end
return { generate_window_properties = main }
