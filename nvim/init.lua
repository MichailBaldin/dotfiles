-- ~/.config/nvim/init.lua
vim.g.mapleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus' -- system clipboard via xclip/wl-clipboard
vim.opt.termguicolors = true

-- tabs & splits
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.splitright = true
vim.opt.splitbelow = true

-- smarter search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- quick saves/quits
vim.keymap.set('n','<leader>w', ':w<CR>')
vim.keymap.set('n','<leader>q', ':q<CR>')

-- move between Vim splits with Ctrl-h/j/k/l
vim.keymap.set('n','<C-h>', '<C-w>h')
vim.keymap.set('n','<C-j>', '<C-w>j')
vim.keymap.set('n','<C-k>', '<C-w>k')
vim.keymap.set('n','<C-l>', '<C-w>l')