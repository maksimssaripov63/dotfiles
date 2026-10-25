return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- 1. Гарантируем поддержку C++ файлов в структуре форматтеров
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.cpp = { "clang-format" }
      opts.formatters_by_ft.cuda = { "clang-format" }

      -- 2. Ювелирно переопределяем аргументы запуска утилиты clang-format
      opts.formatters = opts.formatters or {}
      opts.formatters["clang-format"] = {
        -- Силой заставляем линтер выставить лимит длины строки в 0 (бесконечность!)
        prepend_args = { "-style={BasedOnStyle: Google, ColumnLimit: 0, IndentWidth: 4}" },
      }
    end,
  },
}
