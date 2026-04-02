-- ====================== Basic Settings
-- ========================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "

-- ========================
-- Lazy.nvim (Plugin Manager)
-- ========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP & Autocompletion
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim",          config = true },
  { "williamboman/mason-lspconfig.nvim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets", },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  { "neoclide/coc.nvim",               branch = "release" },
--  { "rafamadriz/friendly-snippets" },
--  { "saadparwaiz1/cmp_luasnip" },
  -- Colors themes
  { "Mofiqul/vscode.nvim" },
  -- Syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  -- Discord rich presencs or "cord.nvim"
  { "vyfor/cord.nvim",                 bulid = ":Cord update" },

  -- autotag
 -- { "windwp/nvim-autopairs" },
  { "mattn/emmet-vim" },
  { "windwp/nvim-ts-autotag" },
  -- quick comment plugin
  { "numToStr/Comment.nvim" },

  --multiselect function
  { "mg979/vim-visual-multi" },
  -- Fuzzy Finder
  { "nvim-telescope/telescope.nvim",   dependencies = { "nvim-lua/plenary.nvim" } },

  -- File Explorer & UI
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons" },
  { "folke/tokyonight.nvim" },

  -- Formatters
  { "mhartington/formatter.nvim" },
  { "stevearc/conform.nvim" },
})

-- ========================
-- Plugins Config
-- ========================



-- Mason
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "html", "cssls", "jsonls", "eslint", "tailwindcss-language-server" },
})
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    typescript = { "prettier" },
  },
})

-- require('nvim-autopairs').setup { map_cr = false }

vim.g.coc_global_extensions = {
  "coc-lua",
  "coc-snippets",
  "coc-html",
  "coc-css",
  "coc-eslint",
  "coc-tsserver",
  "coc-json",
  "coc-tailwindcss",
}

-- https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.lua

-- Some servers have issues with backup files, see #649
vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
-- delays and poor user experience
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved
vim.opt.signcolumn = "yes"

local keyset = vim.keymap.set
-- Autocomplete
function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use Tab for trigger completion with characters ahead and navigate
-- NOTE: There's always a completion item selected by default, you may want to enable
-- no select by setting `"suggest.noselect": true` in your configuration file
-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- other plugins before putting this into your config
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-j> to trigger snippets
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
-- Use <c-space> to trigger completion
keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

-- GoTo code navigation
keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
keyset("n", "gr", "<Plug>(coc-references)", { silent = true })


-- Use K to show documentation in preview window
function _G.show_docs()
  local cw = vim.fn.expand('<cword>')
  if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
    vim.api.nvim_command('h ' .. cw)
  elseif vim.api.nvim_eval('coc#rpc#ready()') then
    vim.fn.CocActionAsync('doHover')
  else
    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
  end
end

keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true })


-- Highlight the symbol and its references on a CursorHold event(cursor is idle)
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
  group = "CocGroup",
  command = "silent call CocActionAsync('highlight')",
  desc = "Highlight symbol under cursor on CursorHold"
})


-- Symbol renaming
keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })


-- Formatting selected code
keyset("x", "<leader>f", "<Plug>(coc-format-selected)", { silent = true })
keyset("n", "<leader>f", "<Plug>(coc-format-selected)", { silent = true })


-- Setup formatexpr specified filetype(s)
vim.api.nvim_create_autocmd("FileType", {
  group = "CocGroup",
  pattern = "typescript,json",
  command = "setl formatexpr=CocAction('formatSelected')",
  desc = "Setup formatexpr specified filetype(s)."
})

-- Apply codeAction to the selected region
-- Example: `<leader>aap` for current paragraph
local opts = { silent = true, nowait = true }
keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

-- Remap keys for apply code actions at the cursor position.
keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
-- Remap keys for apply source code actions for current file.
keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
-- Apply the most preferred quickfix action on the current line.
keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

-- Remap keys for apply refactor code actions.
keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

-- Run the Code Lens actions on the current line
keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)


-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)


-- Remap <C-f> and <C-b> to scroll float windows/popups
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true, expr = true }
keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
keyset("i", "<C-f>",
  'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-b>",
  'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)


-- Use CTRL-S for selections ranges
-- Requires 'textDocument/selectionRange' support of language server
keyset("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true })
keyset("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })


-- Add `:Format` command to format current buffer
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

-- " Add `:Fold` command to fold current buffer
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = '?' })

-- Add `:OR` command for organize imports of the current buffer
vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

-- Add (Neo)Vim's native statusline support
-- NOTE: Please see `:h coc-status` for integrations with external plugins that
-- provide custom statusline: lightline.vim, vim-airline
vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

-- Mappings for CoCList
-- code actions and coc stuff
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true }
-- Show all diagnostics
keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
-- Manage extensions
keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
-- Show commands
keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
-- Find symbol of current document
keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
-- Search workspace symbols
keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
-- Do default action for next item
keyset("n", "<space>j", ":<C-u>CocNext<cr>", opts)
-- Do default action for previous item
keyset("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
-- Resume latest coc list
keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)

-- LSP (Neovim 0.11+ API)
-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
--
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
--
-- vim.lsp.config.ts_ls = { capabilities = capabilities }
-- vim.lsp.config.html = { capabilities = capabilities }
-- vim.lsp.config.cssls = { capabilities = capabilities }
-- vim.lsp.config.jsonls = { capabilities = capabilities }
-- vim.lsp.config.eslint = { capabilities = capabilities }
-- vim.lsp.config.tailwindcss = {capabilities = capabilities}
--
-- vim.lsp.enable("ts_ls")
-- vim.lsp.enable("html")
-- vim.lsp.enable("cssls")
-- vim.lsp.enable("jsonls")
-- vim.lsp.enable("eslint")
-- vim.lsp.enable("tailwindcss")
-- -- Autocompletion (cmp)
-- local cmp = require("cmp")
-- cmp.setup({
--   snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
--   mapping = cmp.mapping.preset.insert({
--     ["<Tab>"] = cmp.mapping.select_next_item(),
--     ["<S-Tab>"] = cmp.mapping.select_prev_item(),
--     ["<CR>"] = cmp.mapping.confirm({ select = true }),
--   }),
--   sources = { { name = "nvim_lsp" } },
-- })
--
--
--   --Lsp go-to-defintion
-- vim.keymap.set("n", "gd", vim.lsp.buf.definition)
-- vim.keymap.set("n", "gr", vim.lsp.buf.references)
-- vim.keymap.set("n", "K", vim.lsp.buf.hover)
-- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
-- ========================
-- Treesitter
-- ========================
require("nvim-treesitter").setup({
  ensure_installed = { "lua", "javascript", "typescript", "tsx", "json", "css", "html" },
  highlight = { enable = true },
  view = {
    mapping = {
      list = {
        { key = "o", action = "edit" },
        { key = "v", action = "vsplit" },
        { key = "s", action = "split" },
        { key = "r", action = "rename" },
        { key = "c", action = "copy" },
        { key = "x", action = "cut" },
        { key = "p", action = "paste" },
        { key = "q", action = "close" },
      }
    }
  }

})

vim.keymap.set("n", "<Leader>t", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- ========================
-- autotags
-- ========================

-- require("nvim-autopairs").setup({
--  check_ts = true
--})

require("nvim-ts-autotag").setup({})
-- ========================
-- Telescope
-- ========================
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

-- ========================
-- File Explorer
-- ========================
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })


-- ========================
-- Theme / Colors
-- =======================
vim.cmd.colorscheme("tokyonight")




-- =======================
-- Formatter.nvim
-- =======================
local prettier = vim.fn.expand("~/.local/share/nvim/mason/bin/prettier")

require("formatter").setup({
  logging = true, -- turn on logging to see errors
  filetype = {
    javascript = {
      function()
        return {
          exe = prettier,
          args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
          stdin = true,
        }
      end
    },
    typescript = {
      function()
        return {
          exe = prettier,
          args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
          stdin = true,
        }
      end
    },
    typescriptreact = {
      function()
        return {
          exe = prettier,
          args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
          stdin = true,
        }
      end
    },
    javascriptreact = {
      function()
        return {
          exe = prettier,
          args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
          stdin = true,
        }
      end
    },
  }
})


-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function() vim.cmd("Format") end,
})
