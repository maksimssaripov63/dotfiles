-- ---- 💻 УЛЬТИМАТИВНАЯ НАСТРОЙКА CLANGD ДЛЯ PLATFORMIO В LAZYVIM ----
return {
  -- Подключаем базовый слой C++
  { import = "lazyvim.plugins.extras.lang.clangd" },

  -- Тонко настраиваем lspconfig, чтобы clangd всегда искал compile_commands.json
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-boundary-check",
            -- 🎯 Главный бронебойный флаг: заставляет искать базу путей в корне проекта
            "--compile-commands-dir=.",
          },
        },
      },
    },
  },
}
