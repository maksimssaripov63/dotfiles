local function setup_my_theme()
  -- Задаем кастомные цвета поверх базовой темы industry
  local custom_highlights = {
    -- [Интерфейс редактора]
    Normal = { fg = "#ffffff", bg = "#101010" }, -- Основной текст и фон всего окна
    CursorLine = { bg = "#002000" }, -- Строка под курсором
    LineNr = { fg = "#555555" }, -- Относительные номера строк
    CursorLineNr = { fg = "#ffff00", bold = true }, -- Абсолютный номер текущей строки
    Visual = { bg = "#3a3a3a" }, -- Цвет выделения текста мышкой

    -- [Синтаксис кода C++ / Arduino]
    Comment = { fg = "#00ff00", italic = true }, -- Комментарии
    Keyword = { fg = "#ff00ff", bold = true }, -- Ключевые слова
    Function = { fg = "#00ffff" }, -- Названия функций
    String = { fg = "#ffaa00" }, -- Текст в кавычках
    Number = { fg = "#ff0000" }, -- Числа и регистры
    Type = { fg = "#55ffff" }, -- Типы данных
  }

  for group, settings in pairs(custom_highlights) do
    vim.api.nvim_set_hl(0, group, settings)
  end
end

-- Регистрируем настройки в пакетном менеджере
return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- Заставляем LazyVim включать ОФИЦИАЛЬНУЮ тему industry при старте
      colorscheme = "industry",
    },
    init = function()
      -- Создаем команду для мгновенного перезапуска цветов на ходу
      vim.api.nvim_create_user_command("ThemeReload", setup_my_theme, {})

      -- Запускаем наложение наших цветов сразу после старта ядра
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "industry",
        callback = setup_my_theme,
      })
    end,
  },
}
