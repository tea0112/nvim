return {
    "mfussenegger/nvim-lint",
    config = function()
        local lint = require("lint")
        -- local flake8 = lint.linters.flake8
        -- flake8.args = {
        --
        -- }

        lint.linters_by_ft = {
            python = { "flake8" },
            -- sh = { "shellcheck" },
        }
    end,
}
