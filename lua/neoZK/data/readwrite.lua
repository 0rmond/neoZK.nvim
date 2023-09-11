local open = io.open
local HOME = os.getenv("HOME")
local lfunc = require("fun")

--- Grabs ALL text from a note.
--- @param path string The path to the note
--- @return nil | string
--
local function get_raw_text(path)
    local file, err = open(path, "rb")
    if not file then return nil end

    local content = file:read("*a")
    file:close()
    return content
end


local function get_lines(paragraphs)
    local everything_before_newlines =  "[^\n]+"

    return paragraphs:gmatch(everything_before_newlines)
end


--- Note metadata is expected to be ~three lines long. It appears in the following order:
---     (1.) Document class of the zettelkasten
---     (2.) Date and time that the note was made;
---     (3.) Title of the note;
---     (4.) Tags associated with the note. Words of a tag are seperated by hyphens, '-', tags themselves are seperated by spaces.
--- The metadata MUST end in (4.) for this function to work as intended.
--- @param lines_getter function gmatch iterator function that gets each line
--- @param ... string each line added as a new paramaeter
--- @return table { (4.), (3.), (2.), (1.)}
--
local function get_note_metadata(lines_getter, ...)

    local line_text = lines_getter()
    local line_contains_tags = line_text:match("^%%tags") ~= nil

    if line_contains_tags then return { line_text, ... } end

    return get_note_metadata(lines_getter, line_text, ...)
end


--- @param note_raw_text string
--- @return string
--
local function get_note_content(note_raw_text)
    local content_between_document_environment = "\\begin{document}\n(.*)\n\\end{document}"
    return note_raw_text:match(content_between_document_environment)
end


--- @param note_raw_text string
--- @return string
--
local function get_note_title(note_raw_text)
    local title = "\\what{([^}]+)}"
    return note_raw_text:match(title)
end


--- @param note_raw_text string
--- @return string
--
local function get_note_date(note_raw_text)
    local time = "\\when{([^}]+)}"
    return note_raw_text:match(time)
end

--- @param tagline string The line of text from a note corresponding to the tags. Starts with %tags
--- @return function gmatch iterator function
local function get_tag_from_tagline(tagline)
    return tagline:gmatch("([%w%-^%d%%]+)")
end

--- Recursively grabs each tag of a note in REVERSE ORDER.
--- @param tag_getter function
--- @return table tags reverse order
local function get_note_tags(tag_getter, ...)
    local tag = tag_getter()

    -- base case
    if not tag then return { ... } end

    --ignore the %tags marker
    if tag == "%tags" then tag = nil end

    return get_note_tags(tag_getter, tag, ...)
end


return {
    get_raw_text = get_raw_text,
    get_metadata = get_note_metadata,
    get_lines = get_lines,
    get_content = get_note_content,
    get_title = get_note_title,
    get_date = get_note_date,
    get_tags = get_note_tags,
    get_tag_from_tagline = get_tag_from_tagline,
}

