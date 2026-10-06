return {
  -- lsp-zero v3.x
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
    init = function()
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },
  -- Mason (lazy=false : charge EN PREMIER)
  {
    'williamboman/mason.nvim',
    lazy = false,  -- Fix : Chargé avant mason-lspconfig
    opts = { auto_install = true },
  },
  -- Mason-LSPConfig (après Mason)
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
  },
  -- LSPConfig (après tout)
  {
    'neovim/nvim-lspconfig',
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'williamboman/mason-lspconfig.nvim' },
    },
    config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_lspconfig()

      lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({ buffer = bufnr })
      end)

      -- Noms VALIDES lspconfig (pas Mason packages)
      require('mason-lspconfig').setup({
        ensure_installed = {
          'lua_ls',       -- Lua
          'ts_ls',        -- TypeScript/JS (valide, remplace ts_ls)
          'eslint',       -- ESLint
          'html',         -- HTML (valide)
          'intelephense', -- PHP (valide)
        },
        automatic_installation = true,
        handlers = {
          -- Default pour tous
          function(server_name)
            require('lspconfig')[server_name].setup({})
          end,
          -- Custom lua_ls
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
          end,
          -- Custom ts_ls (inlay hints)
          ts_ls = function()
            require('lspconfig').ts_ls.setup({
              on_attach = lsp_zero.on_attach,
              settings = {
                typescript = {
                  inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                  },
                },
              },
            })
          end,
        },
      })
    end,
  },
  -- Snippets et cmp (comme avant, v3)
  {
    'L3MON4D3/LuaSnip',
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'L3MON4D3/LuaSnip' },
      { 'hrsh7th/cmp-nvim-lua' },
    },
    config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_cmp()

      local cmp = require('cmp')
      local cmp_action = lsp_zero.cmp_action()
      require('luasnip.loaders.from_vscode').lazy_load()

      cmp.setup({
        formatting = lsp_zero.cmp_format({ details = true }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }),
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
      })
    end,
  },
}