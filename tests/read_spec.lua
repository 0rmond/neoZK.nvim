local zett_dir = "./mock_notes/"
local note = "202306222036.tex"
local readnote = require("neoZK.data.readwrite")

--{{{1 TEST STRINGS 
local RAW = vim.fn.system("cat mock_notes/"..note)
local CONTENT = vim.fn.system("cat mock_notes/content.txt | head -c -1")

local TITLE = "Vast and Roc"
local DATE = "2023 June 22    20:36:26"
local TAGS = "%tags zhuang-zi chapter-one Roc Vast"
--}}}1

describe("Reading a Zettelkasten note:", function()

    local raw_content_results
    before_each(function()
        raw_content_results = readnote.get_raw_text(zett_dir .. note)
    end)

    it("Can get the raw text of a note", function()
        assert.are.equal(RAW, raw_content_results)
    end)

    it("Can seperate out a multi-line string", function()
        local test_string = "line1\nline2\nline3"
        local line_getter = readnote.get_lines(test_string)

        assert.are.equal("line1", line_getter())
        assert.are.equal("line2", line_getter())
        assert.are.equal("line3", line_getter())
    end)

    it("Can get the content of the note", function()

        local content = readnote.get_content(raw_content_results)

        assert.are.equal(CONTENT, content)
    end)

    describe("Reading a note's metadata:", function()
        local metadata
        before_each(function()
            local line_getter = readnote.get_lines(raw_content_results)
            metadata = readnote.get_metadata(line_getter)
        end)

        it("Can get a note's title", function()
            local title_from_raw_content = readnote.get_title(RAW)
            local title_from_metadata = readnote.get_title(metadata[2])

            assert.are.equal(TITLE, title_from_raw_content)
            assert.are.equal(TITLE, title_from_metadata)
        end)

        it("Can get a note's date", function()
            local date_from_raw_content = readnote.get_date(RAW)
            local date_from_metadata = readnote.get_date(metadata[3])
            print(date_from_metadata, date_from_raw_content)

            assert.are.equal(DATE, date_from_raw_content)
            assert.are.equal(DATE, date_from_metadata)
        end)
    end)

end)
