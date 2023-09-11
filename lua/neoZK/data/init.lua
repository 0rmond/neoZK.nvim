local windows = require("neoZK.window")

local function get_results_files(res, ...)
    if #res == 1 then
        return {...}
    end
    return get_results_files(
        {unpack(res, 2)}, string.match(res[1], "([^:]+)"), ...
    )
end

local function generate_cmd(tag, where_to_search)
    if type(where_to_search) == "table" then
        return "rg %tags "..table.concat(where_to_search, " ").." -t tex | rg "..tag
    end
    return "rg %tags "..where_to_search.." -t tex | rg "..tag
end

