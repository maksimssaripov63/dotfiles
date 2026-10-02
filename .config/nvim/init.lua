-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- ---- 💻 УЛЬТИМАТИВНЫЙ БЛОК АВТОДОПОЛНЕНИЯ И LSP ДЛЯ C++ / ARDUINO ----
return {
  -- 1. Движок автодополнения (Показывает всплывающее меню при вводе)
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', -- Поддержка дополнений от LSP
      'hrsh7th/cmp-buffer',   -- Дополнения слов из текущего файла
      'hrsh7th/cmp-path',     -- Дополнение путей к файлам при вводе
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enter подтверждает выбор!
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item() else fallback() end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim-lsp' },
          { name = 'buffer' },
          { name = 'path' },
        })
      end)
    end
  },

  -- 2. Автоматический установщик языковых серверов (Mason)
  {
    'williamboman/mason.nvim',
    opts = { ui = { border = "rounded" } }
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = { ensure_installed = { "clangd" } } -- Автоматом ставим и настраиваем сервер для C++
  },

  -- 3. Быстрая интеграция LSP настроек
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')
      -- Подключаем сервер clangd с флагами быстродействия
      lspconfig.clangd.setup({
        cmd = { "clangd", "--background-index", "--clang-boundary-check" }
      })
    end
  }
}
