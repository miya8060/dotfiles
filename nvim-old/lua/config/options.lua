vim.g.maplocalleader = ' '
vim.wo.number = true
vim.opt.laststatus = 3
vim.opt.cursorline = true
vim.opt.virtualedit = "none"
vim.o.cmdheight = 0
vim.o.laststatus = 0
vim.opt.fillchars = {
        stl = '─',
        stlnc = '─',
}
vim.opt.statusline = '─'
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.breakindent = true
vim.opt.wrap = true
vim.opt.swapfile = false
vim.cmd("set ignorecase")
vim.cmd("set completeopt=menuone,noinsert")
vim.cmd([[let maplocalleader = ' ']])
vim.cmd("filetype indent plugin on")
vim.cmd("syntax on")
vim.cmd("set termguicolors")
