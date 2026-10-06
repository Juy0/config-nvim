vim.g.mapleader = ' '
vim.g.ale_disable_lsp = 1  -- Évite conflits ALE/LSP

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup Lazy
require("lazy").setup({
  spec = {
    -- Import auto depuis lua/j/plugins/*.lua (lsp-zero.lua, nvim-tree.lua, etc.)
    { import = "j.plugins" },
    -- Fallback inline (si import bugge, commente l'import ci-dessus)
    -- Thème Gruvbox
    -- {
    --  "ellisonleao/gruvbox.nvim",
    --  priority = 1000,
    --  config = function()
    --    vim.o.background = "dark"
    --    vim.cmd([[colorscheme gruvbox]])
    --    --  Annulation du theme de fond
    --    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    --    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    --  end,
   --  },
    -- Telescope
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      },
      config = function()
        require('telescope').setup({
          extensions = { fzf = { fuzzy = true, case_mode = "smart_case" } }
        })
        require('telescope').load_extension('fzf')
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      end,
    },
    -- ALE
    {
      "dense-analysis/ale",
      ft = { "python", "sh", "rust" },
      config = function()
        vim.g.ale_linters_explicit = 1
        vim.g.ale_fix_on_save = 1
        vim.g.ale_linters = {
          python = { 'flake8' },
          sh = { 'shellcheck' },
          rust = { 'analyzer' }
        }
        vim.g.ale_fixers = {
          python = { 'black' },
          rust = { 'rustfmt' }
        }
      end,
    },
    -- Tmux-navigator
    {
      "christoomey/vim-tmux-navigator",
      config = function()
        vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
        vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
        vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
        vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })
      end
    },
    -- Icônes
    { "nvim-tree/nvim-web-devicons", opts = { default = true } },
  },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})

require("j.theme_sync")

-- Configs de base Neovim
vim.opt.clipboard = 'unnamedplus'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
