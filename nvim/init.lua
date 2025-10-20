-- ~/.config/nvim/init.lua
-- base setup
vim.g.mapleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- hotkeys
vim.keymap.set('n','<leader>w', ':w<CR>')
vim.keymap.set('n','<leader>q', ':q<CR>')
vim.keymap.set('n','<C-h>', '<C-w>h')
vim.keymap.set('n','<C-j>', '<C-w>j')
vim.keymap.set('n','<C-k>', '<C-w>k')
vim.keymap.set('n','<C-l>', '<C-w>l')

-- lazy vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- plaguin
require("lazy").setup({
  -- theme
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = { style = "night" } },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", build = ":MasonUpdate", config = true },
  { "williamboman/mason-lspconfig.nvim" },

  -- autocomplete
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- highlight
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
})

-- theme
vim.cmd.colorscheme("tokyonight")

--  Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "go", "lua", "vim", "bash", "json", "yaml", "markdown" },
  highlight = { enable = true },
})


--  nvim-cmp
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end,
  },
  mapping = {
    ["<C-n>"]    = cmp.mapping.select_next_item(),
    ["<C-p>"]    = cmp.mapping.select_prev_item(),
    ["<C-Space>"]= cmp.mapping.complete(),
    ["<C-y>"]    = cmp.mapping.confirm({ select = true }),
    ["<Esc>"]    = cmp.mapping.abort(),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "buffer" },
  },
  experimental = { ghost_text = true },
})


--  LSP: setup and Go (gopls)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("mason-lspconfig").setup({
  ensure_installed = { "gopls" }, -- gopls
  automatic_installation = true,
})

-- LSP hotkeys
local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr }) end
  map("n", "gd", vim.lsp.buf.definition)        -- перейти к определению
  map("n", "gr", vim.lsp.buf.references)        -- найти вхождения
  map("n", "gi", vim.lsp.buf.implementation)    -- реализации
  map("n", "K",  vim.lsp.buf.hover)             -- подсказка под курсором
  map("n", "<leader>rn", vim.lsp.buf.rename)    -- переименовать символ
  map("n", "<leader>ca", vim.lsp.buf.code_action) -- действия (quick fix)
  map("n", "[d", vim.diagnostic.goto_prev)      -- пред. диагностика
  map("n", "]d", vim.diagnostic.goto_next)      -- след. диагностика
  map("n", "<leader>e", vim.diagnostic.open_float) -- окно с ошибкой
  map("n", "<leader>f", function() vim.lsp.buf.format({ async = false }) end) -- форматирование
end

-- gopls
require("lspconfig").gopls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    gopls = {
      staticcheck = true,
      gofumpt = true,
      analyses = { unusedparams = true, nilness = true, shadow = true },
    },
  },
})

-- format before save
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function() pcall(vim.lsp.buf.format, { async = false }) end
})

-- logs
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
})
