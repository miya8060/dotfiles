local opts = { silent = true }
local modes = { 'n', 'v' }
local keymap = vim.keymap.set
vim.g.mapleader = " "


-- keymaps
keymap("i", "jj", "<ESC>", opts)
keymap('c', 'jj', '<C-c>', opts)
keymap("i", "jj", "<C-[><C-[>", opts)
keymap("n", "<C-[><C-[>", ":noh<CR>", opts)
keymap("n", "s", "<C-w>", opts)
keymap("n", "ss", ":split<Return>", opts)
keymap("n", "sv", ":vsplit<Return>", opts)
keymap("n", "<c-p>", "{", opts)
keymap("n", "<c-n>", "}", opts)
keymap('n', 'te', ':tabedit', opts)
keymap('n', '<tab>', ':tabnext<Return>', opts)
keymap('n', '<s-tab>', ':tabprev<Return>', opts)
keymap('n', 'sf', function()
        local file_dir = vim.fn.expand('%:p:h')
        local cwd = vim.fn.getcwd()
        local search_path = file_dir ~= cwd and file_dir or cwd
        vim.fn['ddu#start']({
                name = 'filer',
                searchPath = search_path
        })
end, opts)

keymap('n', '<leader>f', function()
        vim.fn['ddu#start']({
                name = 'ff',
        })
end, opts)

keymap('n', '<leader>m', function()
        vim.fn['ddu#start']({
                name = 'ff-mr',
        })
end, opts)

keymap('n', '<leader>b', function()
        vim.fn['ddu#start']({
                name = 'ff-buffer',
        })
end, opts)

keymap('n', 'gs', function()
        vim.fn['ddu#start']({
                name = 'ff-git_status',
        })
end, opts)
-- keymap("n", "<C-j>", "<cmd>bprev<CR>")
-- keymap('n', '<C-k>', '<cmd>bnext<CR>')
keymap("t", "<Esc>", [[<C-\><C-n>]])
keymap("n", "np", "<cmd>NoNeckPain<CR>", opts)
keymap("n", "df",
        "<cmd>call deol#start({ 'cwd': '%'->expand()->fnamemodify(':h'), 'split': 'floating', 'floating_border': 'rounded'})<CR>",
        opts)
keymap("n", "db", "<cmd>call deol#start({ 'cwd': '%'->expand()->fnamemodify(':h') })<CR>", opts)
keymap('x', 'p', 'P', opts)
keymap('x', 'y', 'mzy`z', opts)
keymap('x', '<', '<gv', opts)
keymap('x', '>', '>gv', opts)
keymap('n', 'U', '<C-r>', opts)

-- Gin shortcuts
keymap('n', 'S', '<cmd>GinStatus<CR>', opts)
keymap('n', 'L', '<cmd>GinLog --graph --oneline<CR>', opts)
keymap('n', 'D', '<cmd>GinDiff<CR>', opts)
vim.api.nvim_create_autocmd("FileType", {
        pattern = { 'gin-diff', 'gin-log', 'gin-status' },
        callback = function()
                local opts = { buffer = true, noremap = true }
                keymap('n', 'c', '<cmd>Gin commit<CR>', opts)
                keymap('n', 'q', '<cmd>bdelete<CR>', opts)
        end
})

-- GitDiff
keymap('n', '<Leader>d', ':GitDiff<CR>', opts)
