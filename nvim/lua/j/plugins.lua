return {
  -- Gestionnaire de thème
  -- {
  -- "ellisonleao/gruvbox.nvim",
  --  priority = 1000,
  --  config = true,
  --},

  -- Explorateur de fichiers
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
   u},
    config = function()
      require("nvim-tree").setup {}
    end,
  },

  -- Telescope (recherche de fichiers)
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
      },
    },
    config = function()
      require('telescope').setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })
      require('telescope').load_extension('fzf')
    end,
  },

  -- Mason (gestionnaire LSP/linters/formatters) - HAUTE PRIORITÉ
  {
    "williamboman/mason.nvim",
    priority = 1001,  -- Priorité plus élevée que les autres plugins
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { 
          "lua_ls", 
          "ts_ls",
          "eslint",
          "html",
          "intelephense"  -- Ajouté explicitement
        },
        automatic_installation = true,
      })
    end,
  },

  -- Configuration LSP - SIMPLIFIÉE
  {
    "neovim/nvim-lspconfig",
    dependencies = { 
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
    },
    config = function()
      -- Configuration manuelle de chaque serveur
      local lspconfig = require('lspconfig')
      
      -- Liste des serveurs à configurer
      local servers = {
        "lua_ls",
        "ts_ls",
        "eslint",
        "html",
        "intelephense"
      }
      
      -- Configuration de base pour tous les serveurs
      for _, server_name in ipairs(servers) do
        lspconfig[server_name].setup({})
      end
    end,
  },

  -- ALE - Désactivé pour les langages gérés par Mason
  {
    "dense-analysis/ale",
    ft = { "python", "sh", "rust" },  -- Exclut JS/TS/PHP
    config = function()
      vim.g.ale_linters_explicit = 1
      vim.g.ale_disable_lsp = 1  -- Empêche ALE de gérer les LSP
    end,
  },

  -- Icônes pour nvim-tree et autres
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      default = true,
    }
  },

  -- Plenary (requis par telescope)
  {
    "nvim-lua/plenary.nvim",
  },
}
