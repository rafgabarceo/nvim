local map = vim.keymap.set
local set = vim.opt

-- Set the leader to \
map("n", "\\", "<Nop>", {silent = true, remap = false})
-- Set netrw to open on \ex
map("n", "<Leader>ex", ":Ex<Return>")
vim.g.mapleader = "\\"

set.number = true
set.relativenumber = true
set.hlsearch = false
set.expandtab = true

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

-- Setup the plugins
require("lazy").setup({
  {"neovim/nvim-lspconfig"},
  {"williamboman/mason.nvim"},
  {"williamboman/mason-lspconfig.nvim"},
  {"ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ...},
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
        -- Next, you can provide a dedicated handler for specific servers.
        -- For example, a handler override for the `rust_analyzer`:
        ["rust_analyzer"] = function ()
            require("rust-tools").setup {}
        end
}

-- Setup the theme: Gruvbox
vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])
