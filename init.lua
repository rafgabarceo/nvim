local map = vim.keymap.set
local set = vim.opt

map("n", "<Space>", "<Nop>", {silent = true, remap = false})
vim.g.mapleader = " "

map("n", "<Leader>ex", ":Ex<Return>")
set.number = true
set.relativenumber = true
set.hlsearch = false
set.expandtab = true
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4

-- Install lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.signcolumn = "yes"

-- Setup the plugins
require("lazy").setup({
  {"neovim/nvim-lspconfig"},
  {"hrsh7th/nvim-cmp"},
  {"hrsh7th/cmp-nvim-lsp"},
  {"williamboman/mason.nvim"},
  {"williamboman/mason-lspconfig.nvim"},
  {"ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ...},
  {"nvim-telescope/telescope.nvim", dependencies = {"nvim-lua/plenary.nvim"}},
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
  {"tpope/vim-fugitive"},
  {"mfussenegger/nvim-lint"}
})

-- Setup mason
require("mason").setup({})
require("mason-lspconfig").setup({})

-- Automatically setup the language servers.
require("mason-lspconfig").setup_handlers {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function (server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup {}
        end,
}

-- Configure the language server
local cmp = require('cmp');
cmp.setup({
    sources = {
        {name = 'nvim_lsp'}
    },
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end
    },
    mapping = cmp.mapping.preset.insert({}),
})

-- Setup telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {}) vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', 'fr', builtin.lsp_references, { noremap = true, silent = true })

-- Setup treesitter
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "javascript", "typescript", "python"},

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
});

require("lint").linters_by_ft = {
    markdown = {"vale"}
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()

    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require("lint").try_lint()
  end,
})

vim.cmd.colorscheme "gruvbox"
