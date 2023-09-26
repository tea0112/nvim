local M = {}

function M.setup()
    require("indent_blankline").setup({
        space_char_blankline = " ",
        show_end_of_line = true,
        -- for example, context is off by default, use this to turn it on
        show_current_context = true,
        show_current_context_start = true,
        char_highlight_list = {
            "IndentBlanklineIndent1",
            "IndentBlanklineIndent2",
            "IndentBlanklineIndent3",
            "IndentBlanklineIndent4",
            "IndentBlanklineIndent5",
            "IndentBlanklineIndent6",
        },
    })
end

return M
