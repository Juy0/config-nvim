return {
  "nvim-tree/nvim-tree.lua",
  version = "*",  -- Ou "* " si tu veux la dernière stable
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",  -- Icônes pour les fichiers
  },
  config = function()
    -- Désactive Netrw (explorateur Vim par défaut)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- Active les couleurs 24-bit (optionnel, pour un meilleur rendu)
    vim.opt.termguicolors = true

    -- Setup unique avec toutes tes options
    require("nvim-tree").setup({
      -- Disable watcher pour éviter erreurs EPERM sur OneDrive/CloudStorage
      filesystem_watchers = {
        enable = false,  -- Pas de surveillance auto des changements (refresh manuel avec <C-r> si besoin)
      },
      -- Tri case-sensitive
      sort = {
        sorter = "case_sensitive",
      },
      -- Vue
      view = {
        width = 30,  -- Largeur de l'arbre
      },
      -- Renderer
      renderer = {
        group_empty = true,  -- Groupe les dossiers vides
        icons = {
          show = {
            git = true,    -- Icônes Git
            file = false,  -- Pas d'icônes fichiers
            folder = false, -- Pas d'icônes dossiers
            folder_arrow = true,  -- Flèches pour ouvrir/fermer
          },
          glyphs = {
            folder = {
              arrow_closed = "⏵",  -- Flèche fermée
              arrow_open = "⏷",    -- Flèche ouverte
            },
            git = {
              unstaged = "✗",    -- Modifié non-commité
              staged = "✓",      -- Staged
              unmerged = "⌥",    -- Conflit
              renamed = "➜",    -- Renommé
              untracked = "★",   -- Nouveau
              deleted = "⊖",     -- Supprimé
              ignored = "◌",     -- Ignoré
            },
          },
        },
      },
      -- Filtres
      filters = {
        dotfiles = true,  -- Cache les fichiers cachés (.git, etc.)
      },
    })

    -- Keymap pour toggle (ajoute si pas déjà global)
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
  end,
}