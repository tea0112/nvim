local M = {}

function M.setup()
    local hop = require("hop")

    local directions = require("hop.hint").HintDirection
    vim.keymap.set("v", "f", function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR })
    end, { remap = true })

    vim.keymap.set("v", "F", function()
        hop.hint_char1({ direction = directions.BEFORE_CURSOR })
    end, { remap = true })

    vim.keymap.set("n", "f", function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR })
    end, { remap = true })

    vim.keymap.set("n", "F", function()
        hop.hint_char1({ direction = directions.BEFORE_CURSOR })
    end, { remap = true })

    vim.keymap.set("n", "t", function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR })
    end, { remap = true })

    vim.keymap.set("n", "T", function()
        hop.hint_char1({ direction = directions.BEFORE_CURSOR })
    end, { remap = true })

    hop.setup({
        -- keys = "etovxqpdygfblzhckisuran",
        keys = "asdfjklghtovxqpybzciurn",
    })
end

return M
