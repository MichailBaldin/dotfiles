-- ~/.config/nvim/init.lua
-- ========= БАЗА =========
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
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- хоткеи окна/сейва
vim.keymap.set('n','<leader>w', ':w<CR>')
vim.keymap.set('n','<leader>q', ':q<CR>')
vim.keymap.set('n','<C-h>', '<C-w>h')
vim.keymap.set('n','<C-j>', '<C-w>j')
vim.keymap.set('n','<C-k>', '<C-w>k')
vim.keymap.set('n','<C-l>', '<C-w>l')

-- ========= BOOTSTRAP lazy.nvim =========
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
    end
    vim.opt.rtp:prepend(lazypath)

    -- ========= ПЛАГИНЫ =========
    require("lazy").setup({
        { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = { style = "night" } },

        -- LSP хелперы + менеджер бинарей
        { "neovim/nvim-lspconfig" },
        { "williamboman/mason.nvim", build = ":MasonUpdate", config = true },

        -- Автодополнение
        { "hrsh7th/nvim-cmp" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "L3MON4D3/LuaSnip" },
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-nvim-lsp-signature-help" },

        -- Скобки + таб-выпрыгивание
        { "windwp/nvim-autopairs" },
        { "abecodes/tabout.nvim", dependencies = { "nvim-treesitter/nvim-treesitter" } },

        -- Treesitter
        { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

        -- Telescope + fzf
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope.nvim", tag = "0.1.6" },
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

        -- Git
        { "lewis6991/gitsigns.nvim" },
    })

    -- Тема
    vim.cmd.colorscheme("tokyonight")

    -- ========= Treesitter =========
    require("nvim-treesitter.configs").setup({
        ensure_installed = { "go", "lua", "vim", "bash", "json", "yaml", "markdown", "dockerfile" },
        highlight = { enable = true },
    })

    -- ========= nvim-cmp =========
    require("luasnip.loaders.from_vscode").lazy_load()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    vim.api.nvim_create_autocmd("TextChangedI", {
        pattern = "*.go",
        callback = function()
        local col = vim.fn.col('.') - 1
        local line = vim.fn.getline('.')
        if col >= 1 and line:sub(col, col) == "." then
            if not cmp.visible() then cmp.complete() end
                end
                end,
    })

    -- хелпер: стоит ли «выпрыгнуть» (есть ли закрывающий символ под курсором)
    local function next_char_is_closer()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1] or ""
    local ch = text:sub(col + 1, col + 1)
    return ch == ")" or ch == "]" or ch == "}" or ch == '"' or ch == "'" or ch == "`"
    end

    local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 then return false end
        local prev = vim.api.nvim_buf_get_text(0, line - 1, col - 1, line - 1, col, {})[1]
        return not prev:match("%s")
        end

        cmp.setup({
            snippet = {
                expand = function(args)
                luasnip.lsp_expand(args.body)
                end,
            },
            completion = {
                autocomplete = { cmp.TriggerEvent.TextChanged },
                keyword_length = 1, -- начинать дополнение с 1 символа
            },
            mapping = {
                ["<CR>"] = cmp.mapping(function(fallback)
                if cmp.visible() and cmp.get_selected_entry() then
                    cmp.confirm({ select = false })
                    elseif cmp.visible() then
                        cmp.confirm({ select = true })
                        else
                            fallback()
                            end
                            end, { "i", "s" }),

                            ["<Tab>"] = cmp.mapping(function(fallback)
                            -- 1) если под курсором закрывающий символ — прыгаем tabout'ом
                            if next_char_is_closer() then
                                local ok = pcall(function() require("tabout").tabout() end)
                                if ok then return end
                                    end
                                    -- 2) иначе стандартный приоритет: меню → сниппет → автокомплит → tabout → fallback
                                    if cmp.visible() then
                                        cmp.select_next_item()
                                        elseif luasnip.expand_or_locally_jumpable() then
                                            luasnip.expand_or_jump()
                                            elseif has_words_before() then
                                                cmp.complete()
                                                else
                                                    local ok = pcall(function() require("tabout").tabout() end)
                                                    if not ok then fallback() end
                                                        end
                                                        end, { "i", "s" }),

                                                        ["<S-Tab>"] = cmp.mapping(function(fallback)
                                                        if cmp.visible() then
                                                            cmp.select_prev_item()
                                                            elseif luasnip.jumpable(-1) then
                                                                luasnip.jump(-1)
                                                                else
                                                                    local ok = pcall(function() require("tabout").backwards_tabout() end)
                                                                    if not ok then fallback() end
                                                                        end
                                                                        end, { "i", "s" }),

                                                                        ["<C-n>"] = cmp.mapping.select_next_item(),
                  ["<C-p>"] = cmp.mapping.select_prev_item(),
                  ["<C-Space>"] = cmp.mapping.complete(),
                  ["<Esc>"] = cmp.mapping.abort(),
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "nvim_lsp_signature_help" },
            }, {
                { name = "buffer" },
                { name = "path" },
            }),
            formatting = {
                format = function(entry, vim_item)
                    vim_item.menu = ({
                        nvim_lsp = "[LSP]",
                        luasnip = "[Snip]",
                        buffer = "[Buf]",
                        path = "[Path]",
                    })[entry.source.name]
                    return vim_item
                    end,
            },
        })

        -- autopairs + cmp
        require("nvim-autopairs").setup({})
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

        -- tabout: Tab/Shift-Tab прыжки из () [] {} "" '' ``
        require("tabout").setup({
            tabkey = "<Tab>",
            backwards_tabkey = "<S-Tab>",
            act_as_tab = true, -- если некуда «табаутить», работает как обычный Tab
            completion = true, -- <— важно: дружить с меню nvim-cmp
            ignore_beginning = true,
            enable_backwards = true,
        })

        -- ========= LSP (vim.lsp.start) =========
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "gi", vim.lsp.buf.implementation, "Implementations")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostic")
        map("n", "<leader>f", function()
        vim.lsp.buf.format({ async = false })
        end, "Format")
        end

        -- gopls путь: mason -> системный
        local mason_gopls = vim.fn.stdpath("data") .. "/mason/bin/gopls"
        local gopls_cmd = (vim.fn.executable(mason_gopls) == 1) and { mason_gopls } or { "gopls" }

        local util = require("lspconfig.util")
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "go",
            callback = function(args)
            local buf = args.buf
            for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
                if c.name == "gopls" then
                    return
                    end
                    end
                    local fname = vim.api.nvim_buf_get_name(buf)
                    local root = util.root_pattern("go.work", "go.mod", ".git")(fname) or vim.fn.getcwd()

                    vim.lsp.start({
                        name = "gopls",
                        cmd = gopls_cmd,
                        root_dir = root,
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            gopls = {
                                staticcheck = true,
                                gofumpt = true,
                                analyses = { unusedparams = true, nilness = true, shadow = true },
                                completeUnimported = true, -- предлагать символы из неимпортированных пакетов и добавлять import при выборе
                                deepCompletion = true, -- более агрессивные подсказки
                                usePlaceholders = true, -- плейсхолдеры аргументов (удобно с Tab)
                            },
                        },
                    })
                    end,
        })

        -- Базовый LSP для распространенных языков
        local lspconfig = require("lspconfig")
        local servers = { "lua_ls", "bashls", "jsonls", "yamlls" }
        for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup({
                capabilities = capabilities,
                on_attach = on_attach,
            })
            end

            -- формат + organize imports для Go
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go",
                callback = function()
                -- organize imports
                local params = vim.lsp.util.make_range_params()
                params.context = { only = { "source.organizeImports" } }
                local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 500)
                for _, res in pairs(result or {}) do
                    for _, r in pairs(res.result or {}) do
                        if r.edit then
                            vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
                            elseif r.command then
                                vim.lsp.buf.execute_command(r.command)
                                end
                                end
                                end
                                -- формат
                                pcall(vim.lsp.buf.format, { async = false })
                                end,
            })

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                update_in_insert = true,
                severity_sort = true,
            })

            -- аккуратные ховеры
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
                border = "rounded",
                max_width = 100,
                max_height = 20,
                focusable = false,
            })
            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                vim.lsp.handlers.signature_help, { border = "rounded", focusable = false }
            )

            -- ========= Telescope =========
            local telescope = require("telescope")
            local actions = require("telescope.actions")
            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-n>"] = actions.move_selection_next,
                            ["<C-p>"] = actions.move_selection_previous,
                            ["<C-y>"] = actions.select_default,
                            ["<C-q>"] = function(prompt_bufnr)
                            actions.smart_send_to_qflist(prompt_bufnr)
                            actions.open_qflist(prompt_bufnr)
                            end,
                        },
                    },
                },
                pickers = { find_files = { hidden = true } },
            })
            pcall(telescope.load_extension, "fzf")

            vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Files" })
            vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Grep" })
            vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Buffers" })
            vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help" })
            vim.keymap.set("n", "<leader>fd", require("telescope.builtin").diagnostics, { desc = "Diagnostics" })
            vim.keymap.set("n", "<leader>fs", require("telescope.builtin").lsp_document_symbols, { desc = "Symbols file" })
            vim.keymap.set("n", "<leader>fS", require("telescope.builtin").lsp_workspace_symbols, { desc = "Symbols workspace" })

            -- ========= Gitsigns =========
            require("gitsigns").setup({ signcolumn = true, current_line_blame = false })
            local gs = package.loaded.gitsigns
            vim.keymap.set("n", "]c", function()
            gs.next_hunk()
            end, { desc = "Next hunk" })
            vim.keymap.set("n", "[c", function()
            gs.prev_hunk()
            end, { desc = "Prev hunk" })
            vim.keymap.set("n", "<leader>hs", function()
            gs.stage_hunk()
            end, { desc = "Stage hunk" })
            vim.keymap.set("n", "<leader>hr", function()
            gs.reset_hunk()
            end, { desc = "Reset hunk" })
            vim.keymap.set("n", "<leader>hp", function()
            gs.preview_hunk()
            end, { desc = "Preview hunk" })
            vim.keymap.set("n", "<leader>hu", function()
            gs.undo_stage_hunk()
            end, { desc = "Undo stage" })
            vim.keymap.set("n", "<leader>hb", function()
            gs.toggle_current_line_blame()
            end, { desc = "Blame line" })
            vim.keymap.set("n", "<leader>hd", function()
            gs.diffthis()
            end, { desc = "Diff file" })
