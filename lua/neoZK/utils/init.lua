local fun = require("fun")
local function unique(tbl, ...)
    -- Outputs a table with only unique values. NB: Output is scrambled.
    local tbl_len = #tbl
    if tbl_len == 0 then return {...} end

    local to_filter_for = tbl[1]
    local reduced_tbl = {unpack(tbl, 2, tbl_len)}

    local function check_if_duplicate(to_check)
        return to_check ~= to_filter_for
    end

    local filtered_tbl = fun.filter(check_if_duplicate, reduced_tbl):totable()

    return unique(filtered_tbl, to_filter_for, ...)

end

local function join(tbl1, tbl2, ...)
    if #tbl1 == 0 then
        if #tbl2 == 0 then return {...} end
        return join(tbl1, {unpack(tbl2,2,#tbl2)}, tbl2[1], ...)
    end

    return join({unpack(tbl1,2,#tbl1)}, tbl2, tbl1[1], ...)
end

return {
    unique=unique,
    join=join,
}

