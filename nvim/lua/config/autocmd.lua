-- colorscheme
vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
                vim.cmd("colorscheme gruvbox")
        end
})

-- Each time a file is opened, automatically navigate to the directory where the file resides
vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
                local dir = vim.fn.expand("%:p:h")
                vim.cmd("silent! lcd " .. vim.fn.fnameescape(dir))
        end
})

vim.api.nvim_create_user_command('GitDiff', function()
        vim.cmd([[
    new
    setlocal buftype=nofile bufhidden=delete noswapfile
    setfiletype gitcommit
    read !git diff #
    setlocal readonly nobuflisted
    syntax enable
    highlight gitcommitComment ctermfg=gray guifg=gray
    highlight gitcommitOnBranch ctermfg=blue guifg=blue
    highlight gitcommitSelectedFile ctermfg=green guifg=green
    highlight gitcommitDiscardedFile ctermfg=red guifg=red
    normal! gg
  ]])
end, {})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "WinEnter" }, {
        callback = function() vim.opt_local.scrolloff = math.floor((vim.fn.line('w$') - vim.fn.line('w0')) * 0.2) end
})

function AllBuffers()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, "AllBuffers")

        vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
        vim.api.nvim_buf_set_option(buf, 'swapfile', false)

        local function should_exclude(bufnr)
                local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
                local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
                local bufname = vim.api.nvim_buf_get_name(bufnr)

                return buftype ~= ""
                    or filetype == 'qf'
                    or filetype == 'help'
                    or filetype == 'git'
                    or bufname:match("^%[.*%]$")
                    or bufname == ""
                    or bufnr == buf
        end

        local contents = {}
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(bufnr)
                    and vim.api.nvim_buf_is_loaded(bufnr)
                    and not should_exclude(bufnr) then
                        local bufname = vim.api.nvim_buf_get_name(bufnr)
                        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                        table.insert(contents, string.format("バッファ: %s\n\n%s\n%s\n",
                                vim.fn.fnamemodify(bufname, ":t"),
                                table.concat(lines, "\n"),
                                string.rep("-", 50)))
                end
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(table.concat(contents, "\n"), "\n"))

        vim.cmd('vsplit')
        vim.api.nvim_win_set_buf(0, buf)
end

vim.api.nvim_set_keymap("n", "<leader>ca", "<cmd>lua AllBuffers()<cr>", { noremap = true, silent = true })

vim.api.nvim_create_user_command('GitDiff', function()
        local current_file = vim.fn.expand('%')

        vim.cmd('new')
        local buf = vim.api.nvim_get_current_buf()
        vim.bo[buf].buftype = 'nofile'
        vim.bo[buf].bufhidden = 'delete'
        vim.bo[buf].swapfile = false
        vim.bo[buf].filetype = 'diff'

        local output = vim.fn.systemlist('git diff ' .. current_file)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

        vim.bo[buf].readonly = true
        vim.bo[buf].buflisted = false

        vim.keymap.set('n', 'q', ':q<CR>', { buffer = buf, silent = true })

        vim.cmd('normal! gg')
end, {})
