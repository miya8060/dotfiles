local insx = require("insx")

require("insx.preset.standard").setup({
        cmdline = { enabled = true },
        fast_break = { enabled = true },
        fast_wrap = { enabled = false },
        spacing = { enabled = true },
})

insx.add(
        '<C-[>',
        require('insx.recipe.fast_wrap')({
                close = ')'
        })
)
